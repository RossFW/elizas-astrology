import SwiftUI

// MARK: - Big Three Display

struct BigThreeView: View {
    let chart: NatalChart

    var body: some View {
        HStack(spacing: 20) {
            signPill(label: "Sun", sign: chart.sunSign)
            signPill(label: "Moon", sign: chart.moonSign)
            signPill(label: "Rising", sign: chart.risingSign)
        }
    }

    private func signPill(label: String, sign: ZodiacSign) -> some View {
        VStack(spacing: 4) {
            Text(sign.symbol)
                .font(.title)
            Text(sign.name)
                .font(.caption)
                .fontWeight(.semibold)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(sign.element.color.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Transit Card

struct TransitCard: View {
    let transit: Transit

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(transit.transitingPosition.body.symbol)
                    .font(.title2)
                Text(transit.aspectType.symbol)
                    .font(.title3)
                    .foregroundStyle(.secondary)
                Text(transit.natalPosition.body.symbol)
                    .font(.title2)

                Spacer()

                if transit.aspectType.isHarmonious {
                    Image(systemName: "sparkle")
                        .foregroundStyle(.green)
                } else {
                    Image(systemName: "bolt.fill")
                        .foregroundStyle(.orange)
                }
            }

            Text("\(transit.transitingPosition.body.name) \(transit.aspectType.name) your \(transit.natalPosition.body.name)")
                .font(.subheadline)
                .fontWeight(.semibold)

            Text(TransitInterpretations.interpret(transit))
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(4)
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Retrograde Badge

struct RetrogradeBadge: View {
    let info: RetrogradeInfo

    var body: some View {
        HStack(spacing: 6) {
            Text(info.body.symbol)
                .font(.caption)
            Text("Rx")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundStyle(.red)
            Text(info.sign.symbol)
                .font(.caption)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.red.opacity(0.1))
        .clipShape(Capsule())
    }
}

// MARK: - Planet Row

struct PlanetRow: View {
    let position: CelestialPosition
    let house: Int?

    var body: some View {
        HStack {
            Text(position.body.symbol)
                .font(.title2)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(position.body.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(position.formattedDegree)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(position.sign.symbol)
                    .font(.title3)
                if let house = house {
                    Text("House \(house)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            if position.isRetrograde {
                Text("Rx")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(.red)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(Color.red.opacity(0.1))
                    .clipShape(Capsule())
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Aspect Row

struct AspectRow: View {
    let aspect: ChartAspect

    var body: some View {
        HStack {
            Text(aspect.body1.symbol)
                .font(.title3)
            Text(aspect.type.symbol)
                .font(.caption)
                .foregroundStyle(aspect.type.isHarmonious ? .green : .orange)
            Text(aspect.body2.symbol)
                .font(.title3)

            Spacer()

            VStack(alignment: .trailing) {
                Text(aspect.type.name)
                    .font(.caption)
                Text(String(format: "%.1f\u{00B0} orb", aspect.orb))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Section Header

struct SectionHeader: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundStyle(.purple)
            Text(title)
                .fontWeight(.semibold)
        }
        .font(.headline)
    }
}

// MARK: - Harmony Gauge

struct HarmonyGauge: View {
    let value: Double

    var color: Color {
        switch value {
        case 70...: .green
        case 40..<70: .yellow
        default: .orange
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 10)
                Circle()
                    .trim(from: 0, to: value / 100)
                    .stroke(color, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                VStack {
                    Text("\(Int(value))")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("harmony")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 100, height: 100)
        }
    }
}
