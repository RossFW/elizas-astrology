import SwiftUI

struct ChartWheelView: View {
    let chart: NatalChart
    let size: CGFloat

    private let signColors: [Color] = [
        .red, .green, .yellow, .blue, .red, .green,
        .yellow, .blue, .red, .green, .yellow, .blue,
    ]

    var body: some View {
        Canvas { context, canvasSize in
            let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
            let outerRadius = min(canvasSize.width, canvasSize.height) / 2 - 10
            let middleRadius = outerRadius * 0.78
            let innerRadius = outerRadius * 0.55
            let planetRadius = outerRadius * 0.66

            // Draw zodiac ring
            for i in 0..<12 {
                let startAngle = Angle.degrees(Double(i) * 30 - 90 - Double(chart.ascendantLongitude))
                let endAngle = Angle.degrees(Double(i + 1) * 30 - 90 - Double(chart.ascendantLongitude))

                let path = Path { p in
                    p.addArc(center: center, radius: outerRadius,
                             startAngle: startAngle, endAngle: endAngle, clockwise: false)
                    p.addArc(center: center, radius: middleRadius,
                             startAngle: endAngle, endAngle: startAngle, clockwise: true)
                    p.closeSubpath()
                }

                context.fill(path, with: .color(signColors[i].opacity(0.2)))
                context.stroke(path, with: .color(.gray.opacity(0.3)), lineWidth: 0.5)

                // Sign symbol
                let midAngle = Double(i) * 30 + 15 - Double(chart.ascendantLongitude)
                let symbolRadius = (outerRadius + middleRadius) / 2
                let symbolPoint = pointOnCircle(center: center, radius: symbolRadius, angleDeg: midAngle)

                if let sign = ZodiacSign(rawValue: i) {
                    let text = Text(sign.symbol).font(.system(size: outerRadius * 0.09))
                    context.draw(text.foregroundStyle(signColors[i]), at: symbolPoint)
                }
            }

            // Draw house lines
            for i in 0..<12 {
                let houseLon = Double(chart.ascendantSign.rawValue) * 30 + Double(i) * 30
                let angle = houseLon - Double(chart.ascendantLongitude)
                let start = pointOnCircle(center: center, radius: middleRadius, angleDeg: angle)
                let end = pointOnCircle(center: center, radius: innerRadius, angleDeg: angle)

                var line = Path()
                line.move(to: start)
                line.addLine(to: end)
                context.stroke(line, with: .color(.gray.opacity(0.4)), lineWidth: i == 0 ? 2 : 0.5)

                // House number
                let midHouseAngle = angle + 15
                let houseNumPoint = pointOnCircle(center: center, radius: innerRadius * 0.8, angleDeg: midHouseAngle)
                let houseText = Text("\(i + 1)").font(.system(size: outerRadius * 0.06)).foregroundStyle(.secondary)
                context.draw(houseText, at: houseNumPoint)
            }

            // Draw inner circle
            var innerCircle = Path()
            innerCircle.addArc(center: center, radius: innerRadius, startAngle: .zero, endAngle: .degrees(360), clockwise: false)
            context.stroke(innerCircle, with: .color(.gray.opacity(0.3)))

            // Draw middle circle
            var midCircle = Path()
            midCircle.addArc(center: center, radius: middleRadius, startAngle: .zero, endAngle: .degrees(360), clockwise: false)
            context.stroke(midCircle, with: .color(.gray.opacity(0.3)))

            // Draw aspect lines
            for aspect in chart.aspects {
                guard let pos1 = chart.position(for: aspect.body1),
                      let pos2 = chart.position(for: aspect.body2) else { continue }

                let angle1 = pos1.longitude - Double(chart.ascendantLongitude)
                let angle2 = pos2.longitude - Double(chart.ascendantLongitude)
                let p1 = pointOnCircle(center: center, radius: innerRadius * 0.9, angleDeg: angle1)
                let p2 = pointOnCircle(center: center, radius: innerRadius * 0.9, angleDeg: angle2)

                var aspectLine = Path()
                aspectLine.move(to: p1)
                aspectLine.addLine(to: p2)

                let color: Color = aspect.type.isHarmonious ? .blue.opacity(0.3) : .red.opacity(0.3)
                context.stroke(aspectLine, with: .color(color), lineWidth: 0.5)
            }

            // Draw planets
            let planetPositions = spreadPlanets(chart.positions, ascendant: chart.ascendantLongitude)
            for (position, displayAngle) in planetPositions {
                let point = pointOnCircle(center: center, radius: planetRadius, angleDeg: displayAngle)
                let text = Text(position.body.symbol).font(.system(size: outerRadius * 0.1))
                context.draw(text, at: point)

                // Small tick from planet to actual position on wheel
                let actualAngle = position.longitude - chart.ascendantLongitude
                let tickStart = pointOnCircle(center: center, radius: middleRadius, angleDeg: actualAngle)
                let tickEnd = pointOnCircle(center: center, radius: middleRadius - 4, angleDeg: actualAngle)
                var tick = Path()
                tick.move(to: tickStart)
                tick.addLine(to: tickEnd)
                context.stroke(tick, with: .color(.purple), lineWidth: 1.5)
            }

            // ASC marker
            let ascPoint = pointOnCircle(center: center, radius: outerRadius + 4, angleDeg: 0)
            let ascText = Text("ASC").font(.system(size: outerRadius * 0.06)).bold().foregroundStyle(.purple)
            context.draw(ascText, at: ascPoint)

            // MC marker
            let mcAngle = chart.midheavenLongitude - chart.ascendantLongitude
            let mcPoint = pointOnCircle(center: center, radius: outerRadius + 4, angleDeg: mcAngle)
            let mcText = Text("MC").font(.system(size: outerRadius * 0.06)).bold().foregroundStyle(.purple)
            context.draw(mcText, at: mcPoint)
        }
        .frame(width: size, height: size)
    }

    private func pointOnCircle(center: CGPoint, radius: CGFloat, angleDeg: Double) -> CGPoint {
        let angleRad = (angleDeg - 90) * .pi / 180
        return CGPoint(
            x: center.x + radius * cos(angleRad),
            y: center.y + radius * sin(angleRad)
        )
    }

    // Spread overlapping planets so they don't stack on each other
    private func spreadPlanets(_ positions: [CelestialPosition], ascendant: Double) -> [(CelestialPosition, Double)] {
        let sorted = positions.sorted { $0.longitude < $1.longitude }
        var result: [(CelestialPosition, Double)] = []
        let minSpacing = 8.0

        for pos in sorted {
            var displayAngle = pos.longitude - ascendant

            // Check for overlap with already placed planets
            for (_, existingAngle) in result {
                var diff = displayAngle - existingAngle
                if diff > 180 { diff -= 360 }
                if diff < -180 { diff += 360 }
                if abs(diff) < minSpacing {
                    displayAngle = existingAngle + (diff >= 0 ? minSpacing : -minSpacing)
                }
            }

            result.append((pos, displayAngle))
        }

        return result
    }
}
