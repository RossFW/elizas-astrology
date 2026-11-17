import Testing
import Foundation
@testable import Eliza_s_Astro_App

struct EphemerisTests {

    // MARK: - JulianDate.fromDate must not crash on any valid Date

    @Test("JulianDate produces correct JD for J2000 epoch")
    func julianDateJ2000() {
        // J2000.0: 2000-01-01 12:00:00 UTC = JD 2451545.0
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        let j2000 = cal.date(from: DateComponents(year: 2000, month: 1, day: 1, hour: 12, minute: 0, second: 0))!
        let jd = JulianDate.fromDate(j2000)
        #expect(abs(jd - 2451545.0) < 0.001)
    }

    @Test("JulianDate handles Date.distantPast without crashing")
    func julianDateDistantPast() {
        let jd = JulianDate.fromDate(Date.distantPast)
        #expect(jd.isFinite)
    }

    @Test("JulianDate handles Date.distantFuture without crashing")
    func julianDateDistantFuture() {
        let jd = JulianDate.fromDate(Date.distantFuture)
        #expect(jd.isFinite)
    }

    @Test("JulianDate handles current date without crashing")
    func julianDateNow() {
        let jd = JulianDate.fromDate(Date())
        #expect(jd > 2451545.0, "Current JD must be after J2000")
    }

    @Test("JulianDate handles midnight UTC correctly")
    func julianDateMidnight() {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        let midnight = cal.date(from: DateComponents(year: 2024, month: 6, day: 15, hour: 0, minute: 0, second: 0))!
        let jd = JulianDate.fromDate(midnight)
        #expect(jd.isFinite)
        // Midnight JD should end in .5
        let fractional = jd - floor(jd)
        #expect(abs(fractional - 0.5) < 0.001)
    }

    // MARK: - Ephemeris.calculate must produce valid output

    @Test("Ephemeris.calculate returns 11 positions for typical birth data")
    func ephemerisTypicalInput() {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        let date = cal.date(from: DateComponents(year: 1995, month: 6, day: 15, hour: 14, minute: 30, second: 0))!
        let result = Ephemeris.calculate(date: date, latitude: 40.7128, longitude: -74.0060)
        #expect(result.positions.count == 11)
        #expect(result.ascendant >= 0 && result.ascendant < 360)
        #expect(result.midheaven >= 0 && result.midheaven < 360)
    }

    @Test("Ephemeris.calculate does not crash for Unix epoch")
    func ephemerisUnixEpoch() {
        let date = Date(timeIntervalSince1970: 0)
        let result = Ephemeris.calculate(date: date, latitude: 0, longitude: 0)
        #expect(result.positions.count == 11)
    }

    @Test("Ephemeris.calculate does not crash at equator/prime meridian")
    func ephemerisEquator() {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        let date = cal.date(from: DateComponents(year: 2026, month: 3, day: 28, hour: 12))!
        let result = Ephemeris.calculate(date: date, latitude: 0, longitude: 0)
        #expect(result.positions.count == 11)
        for pos in result.positions {
            #expect(pos.longitude >= 0 && pos.longitude < 360, "\(pos.body.name) longitude out of range")
        }
    }

    @Test("Ephemeris.currentPositions returns valid positions")
    func ephemerisCurrentPositions() {
        let positions = Ephemeris.currentPositions()
        #expect(positions.count == 11)
        for pos in positions {
            #expect(pos.longitude >= 0 && pos.longitude < 360)
        }
    }

    @Test("All planet longitudes are in valid 0-360 range")
    func allLongitudesValid() {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        let date = cal.date(from: DateComponents(year: 1985, month: 7, day: 4, hour: 6, minute: 0))!
        let result = Ephemeris.calculate(date: date, latitude: 33.749, longitude: -84.388)
        for pos in result.positions {
            #expect(pos.longitude >= 0, "\(pos.body.name) has negative longitude: \(pos.longitude)")
            #expect(pos.longitude < 360, "\(pos.body.name) has longitude >= 360: \(pos.longitude)")
        }
    }
}
