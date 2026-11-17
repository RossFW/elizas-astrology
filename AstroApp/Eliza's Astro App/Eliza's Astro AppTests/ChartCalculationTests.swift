import Testing
import Foundation
@testable import Eliza_s_Astro_App

struct ChartCalculationTests {

    // MARK: - ZodiacSign

    @Test("ZodiacSign.from(longitude:) maps degrees to correct signs")
    func zodiacSignFromLongitude() {
        #expect(ZodiacSign.from(longitude: 0) == .aries)
        #expect(ZodiacSign.from(longitude: 29.99) == .aries)
        #expect(ZodiacSign.from(longitude: 30) == .taurus)
        #expect(ZodiacSign.from(longitude: 59.99) == .taurus)
        #expect(ZodiacSign.from(longitude: 60) == .gemini)
        #expect(ZodiacSign.from(longitude: 90) == .cancer)
        #expect(ZodiacSign.from(longitude: 120) == .leo)
        #expect(ZodiacSign.from(longitude: 150) == .virgo)
        #expect(ZodiacSign.from(longitude: 180) == .libra)
        #expect(ZodiacSign.from(longitude: 210) == .scorpio)
        #expect(ZodiacSign.from(longitude: 240) == .sagittarius)
        #expect(ZodiacSign.from(longitude: 270) == .capricorn)
        #expect(ZodiacSign.from(longitude: 300) == .aquarius)
        #expect(ZodiacSign.from(longitude: 330) == .pisces)
        #expect(ZodiacSign.from(longitude: 359.99) == .pisces)
    }

    @Test("ZodiacSign.from(longitude:) wraps correctly at 360")
    func zodiacSignWraps() {
        #expect(ZodiacSign.from(longitude: 360) == .aries)
        #expect(ZodiacSign.from(longitude: 390) == .taurus)
        #expect(ZodiacSign.from(longitude: 720) == .aries)
    }

    @Test("ZodiacSign.from(longitude:) handles negative values")
    func zodiacSignNegative() {
        #expect(ZodiacSign.from(longitude: -1) == .pisces)
        #expect(ZodiacSign.from(longitude: -30) == .pisces)
        #expect(ZodiacSign.from(longitude: -31) == .aquarius)
    }

    // MARK: - ChartCalculator

    @Test("ChartCalculator produces complete chart with all positions")
    func calculateChartComplete() {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        let date = cal.date(from: DateComponents(year: 1990, month: 3, day: 21, hour: 10, minute: 0, second: 0))!

        let chart = ChartCalculator.calculateChart(date: date, latitude: 51.5074, longitude: -0.1278)

        #expect(chart.positions.count == 11)
        #expect(chart.ascendantLongitude >= 0 && chart.ascendantLongitude < 360)
        #expect(chart.midheavenLongitude >= 0 && chart.midheavenLongitude < 360)
    }

    @Test("Sun is in Aries around March 21")
    func sunInAriesEquinox() {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        let date = cal.date(from: DateComponents(year: 2024, month: 3, day: 25, hour: 12))!

        let chart = ChartCalculator.calculateChart(date: date, latitude: 0, longitude: 0)
        let sun = chart.position(for: .sun)

        #expect(sun != nil)
        #expect(sun?.sign == .aries)
    }

    @Test("All house numbers are between 1 and 12")
    func chartHousesValid() {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        let date = cal.date(from: DateComponents(year: 1985, month: 12, day: 1, hour: 8))!

        let chart = ChartCalculator.calculateChart(date: date, latitude: 40.7128, longitude: -74.006)

        for pos in chart.positions {
            let house = chart.houseForBody(pos.body)
            #expect(house >= 1 && house <= 12, "House for \(pos.body.name) should be 1-12, got \(house)")
        }
    }

    // MARK: - Aspects

    @Test("AspectCalculator finds at least one aspect in a natal chart")
    func aspectsExist() {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        let date = cal.date(from: DateComponents(year: 1990, month: 1, day: 1, hour: 12))!

        let chart = ChartCalculator.calculateChart(date: date, latitude: 0, longitude: 0)

        #expect(!chart.aspects.isEmpty, "Expected at least one aspect")
    }

    @Test("All aspect orbs are non-negative and within max orb")
    func aspectOrbsValid() {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        let date = cal.date(from: DateComponents(year: 1990, month: 1, day: 1, hour: 12))!

        let chart = ChartCalculator.calculateChart(date: date, latitude: 0, longitude: 0)

        for aspect in chart.aspects {
            #expect(aspect.orb >= 0, "Orb should be non-negative")
            #expect(aspect.orb <= aspect.type.orb, "Orb \(aspect.orb) exceeds max \(aspect.type.orb) for \(aspect.type.name)")
        }
    }

    // MARK: - Transit Engine

    @Test("WeeklyReport produces valid date range and moon sign")
    func weeklyReportValid() {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        let date = cal.date(from: DateComponents(year: 1990, month: 1, day: 1, hour: 12))!

        let chart = ChartCalculator.calculateChart(date: date, latitude: 51.5074, longitude: -0.1278)
        let report = TransitEngine.weeklyReport(for: chart)

        #expect(report.weekStart < report.weekEnd)
        #expect(ZodiacSign.allCases.contains(report.currentMoonSign))
    }

    @Test("Transit significance scoring produces non-negative values")
    func transitSignificanceNonNegative() {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        let date = cal.date(from: DateComponents(year: 1990, month: 1, day: 1, hour: 12))!

        let chart = ChartCalculator.calculateChart(date: date, latitude: 0, longitude: 0)
        let transits = TransitEngine.currentTransits(for: chart)

        for transit in transits {
            #expect(transit.significance >= 0)
        }
    }

    // MARK: - Synastry

    @Test("Synastry harmony score is between 0 and 100")
    func synastryHarmonyRange() {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        let date1 = cal.date(from: DateComponents(year: 1990, month: 1, day: 1, hour: 12))!
        let date2 = cal.date(from: DateComponents(year: 1992, month: 7, day: 15, hour: 8))!

        let chart1 = ChartCalculator.calculateChart(date: date1, latitude: 0, longitude: 0)
        let chart2 = ChartCalculator.calculateChart(date: date2, latitude: 40, longitude: -74)

        let report = SynastryCalculator.compare(chart1: chart1, chart2: chart2)

        #expect(report.overallHarmony >= 0)
        #expect(report.overallHarmony <= 100)
    }

    // MARK: - Placidus Validation

    @Test("Placidus angles and cusps are consistent for a synthetic chart")
    func placidusValidation() {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        let date = cal.date(from: DateComponents(year: 2000, month: 1, day: 1, hour: 12))!
        let chart = ChartCalculator.calculateChart(date: date, latitude: 40.0, longitude: 10.0)
        #expect(chart.houseCusps.count == 12)
        for cusp in chart.houseCusps {
            #expect(cusp >= 0 && cusp < 360)
        }
        #expect(abs(chart.houseCusps[0] - chart.ascendantLongitude) < 0.01)
        #expect(abs(chart.houseCusps[9] - chart.midheavenLongitude) < 0.01)
    }

    // MARK: - CelestialPosition

    @Test("CelestialPosition.degreeInSign is between 0 and 30")
    func degreeInSignRange() {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        let date = cal.date(from: DateComponents(year: 2000, month: 6, day: 15, hour: 12))!

        let result = Ephemeris.calculate(date: date, latitude: 0, longitude: 0)
        for pos in result.positions {
            #expect(pos.degreeInSign >= 0, "\(pos.body.name) degreeInSign < 0")
            #expect(pos.degreeInSign < 30, "\(pos.body.name) degreeInSign >= 30")
        }
    }
}
