import Foundation

// MARK: - Chart Calculator

enum ChartCalculator {
    static func calculateChart(date: Date, latitude: Double, longitude: Double) -> NatalChart {
        let result = Ephemeris.calculate(date: date, latitude: latitude, longitude: longitude)
        let aspects = AspectCalculator.findAspects(positions: result.positions)

        return NatalChart(
            positions: result.positions,
            ascendantLongitude: result.ascendant,
            midheavenLongitude: result.midheaven,
            aspects: aspects
        )
    }

    static func calculateChart(for profile: Profile) -> NatalChart {
        calculateChart(
            date: profile.birthDate,
            latitude: profile.birthLatitude,
            longitude: profile.birthLongitude
        )
    }
}

// MARK: - Aspect Calculator

enum AspectCalculator {
    static func findAspects(positions: [CelestialPosition], orbs: [AspectType: Double]? = nil) -> [ChartAspect] {
        var aspects: [ChartAspect] = []

        for i in 0..<positions.count {
            for j in (i + 1)..<positions.count {
                let p1 = positions[i]
                let p2 = positions[j]

                // Skip North Node aspects for simplicity
                if p1.body == .northNode || p2.body == .northNode { continue }

                if let aspect = checkAspect(pos1: p1, pos2: p2, orbs: orbs) {
                    aspects.append(aspect)
                }
            }
        }

        return aspects
    }

    static func findAspectsBetween(
        transitPositions: [CelestialPosition],
        natalPositions: [CelestialPosition],
        orbs: [AspectType: Double]? = nil
    ) -> [ChartAspect] {
        var aspects: [ChartAspect] = []
        for tp in transitPositions {
            if tp.body == .northNode { continue }
            for np in natalPositions {
                if np.body == .northNode { continue }
                if let aspect = checkAspect(pos1: tp, pos2: np, orbs: orbs) {
                    aspects.append(aspect)
                }
            }
        }
        return aspects
    }

    private static func checkAspect(
        pos1: CelestialPosition,
        pos2: CelestialPosition,
        orbs: [AspectType: Double]?
    ) -> ChartAspect? {
        var diff = abs(pos1.longitude - pos2.longitude)
        if diff > 180 { diff = 360 - diff }

        for aspectType in AspectType.allCases {
            let maxOrb = orbs?[aspectType] ?? aspectType.orb
            let orb = abs(diff - aspectType.angle)
            if orb <= maxOrb {
                return ChartAspect(
                    body1: pos1.body,
                    body2: pos2.body,
                    type: aspectType,
                    orb: orb,
                    isApplying: true // simplified for now
                )
            }
        }
        return nil
    }
}

// MARK: - Transit Engine

struct WeeklyTransitReport {
    let transits: [Transit]
    let retrogrades: [RetrogradeInfo]
    let currentMoonSign: ZodiacSign
    let weekStart: Date
    let weekEnd: Date

    var significantTransits: [Transit] {
        transits.sorted { $0.significance > $1.significance }
    }

    var topTransits: [Transit] {
        Array(significantTransits.prefix(5))
    }
}

enum TransitEngine {
    static func currentTransits(for chart: NatalChart) -> [Transit] {
        let currentPositions = Ephemeris.currentPositions()
        return findTransits(transitPositions: currentPositions, natalChart: chart)
    }

    static func weeklyReport(for chart: NatalChart) -> WeeklyTransitReport {
        let calendar = Calendar.current
        let now = Date()

        // Find start of current week (Monday)
        var weekStart = now
        while calendar.component(.weekday, from: weekStart) != 2 {
            weekStart = calendar.date(byAdding: .day, value: -1, to: weekStart)!
        }
        weekStart = calendar.startOfDay(for: weekStart)
        let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart)!

        // Collect transits across the week, checking midweek for the best snapshot
        let midweek = calendar.date(byAdding: .day, value: 3, to: weekStart)!
        let jd = JulianDate.fromDate(midweek)
        let transitPositions = Ephemeris.calculate(
            jd: jd, latitude: 0, longitude: 0
        ).positions

        let transits = findTransits(transitPositions: transitPositions, natalChart: chart)

        // Current retrogrades
        let retrogrades = findRetrogrades(positions: transitPositions, chart: chart)

        // Current moon sign
        let currentPositions = Ephemeris.currentPositions()
        let moonSign = currentPositions.first { $0.body == .moon }?.sign ?? .aries

        return WeeklyTransitReport(
            transits: transits,
            retrogrades: retrogrades,
            currentMoonSign: moonSign,
            weekStart: weekStart,
            weekEnd: weekEnd
        )
    }

    private static func findTransits(
        transitPositions: [CelestialPosition],
        natalChart: NatalChart
    ) -> [Transit] {
        var transits: [Transit] = []

        // Use tighter orbs for transits than natal aspects
        let transitOrbs: [AspectType: Double] = [
            .conjunction: 5,
            .opposition: 5,
            .trine: 4,
            .square: 4,
            .sextile: 3,
        ]

        for tp in transitPositions {
            if tp.body == .northNode { continue }
            for np in natalChart.positions {
                if np.body == .northNode { continue }
                // Skip Moon transiting Moon (too brief to matter)
                if tp.body == .moon && np.body == .moon { continue }

                var diff = abs(tp.longitude - np.longitude)
                if diff > 180 { diff = 360 - diff }

                for aspectType in AspectType.allCases {
                    let maxOrb = transitOrbs[aspectType] ?? aspectType.orb
                    let orb = abs(diff - aspectType.angle)
                    if orb <= maxOrb {
                        let house = natalChart.house(for: np.longitude)
                        transits.append(Transit(
                            transitingPosition: tp,
                            natalPosition: np,
                            aspectType: aspectType,
                            orb: orb,
                            isApplying: true,
                            houseAffected: house
                        ))
                    }
                }
            }
        }

        return transits
    }

    private static func findRetrogrades(
        positions: [CelestialPosition],
        chart: NatalChart
    ) -> [RetrogradeInfo] {
        positions.compactMap { pos in
            guard pos.isRetrograde, pos.body != .northNode else { return nil }
            return RetrogradeInfo(
                body: pos.body,
                sign: pos.sign,
                houseInChart: chart.house(for: pos.longitude)
            )
        }
    }
}

// MARK: - Compatibility / Synastry

struct SynastryReport {
    let aspects: [ChartAspect]
    let overallHarmony: Double // 0-100

    var harmonious: [ChartAspect] {
        aspects.filter { $0.type.isHarmonious }
    }

    var challenging: [ChartAspect] {
        aspects.filter { !$0.type.isHarmonious }
    }
}

enum SynastryCalculator {
    static func compare(chart1: NatalChart, chart2: NatalChart) -> SynastryReport {
        let aspects = AspectCalculator.findAspectsBetween(
            transitPositions: chart1.positions,
            natalPositions: chart2.positions
        )

        // Calculate harmony score
        var score = 50.0
        for aspect in aspects {
            let weight = 1.0 / max(aspect.orb, 0.5) // tighter orbs count more
            if aspect.type.isHarmonious {
                score += weight * 3
            } else {
                score -= weight * 2
            }
        }
        let harmony = min(100, max(0, score))

        return SynastryReport(aspects: aspects, overallHarmony: harmony)
    }
}
