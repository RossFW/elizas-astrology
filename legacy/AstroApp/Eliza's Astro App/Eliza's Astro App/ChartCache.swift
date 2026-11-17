import Foundation

@MainActor @Observable
final class ChartCache {
    static let shared = ChartCache()

    private var charts: [String: NatalChart] = [:]
    private var reports: [String: WeeklyTransitReport] = [:]

    private func chartKey(date: Date, lat: Double, lon: Double) -> String {
        "\(Int(date.timeIntervalSince1970))_\(Int(lat * 1000))_\(Int(lon * 1000))"
    }

    func chart(date: Date, latitude: Double, longitude: Double) async -> NatalChart {
        let key = chartKey(date: date, lat: latitude, lon: longitude)
        if let cached = charts[key] { return cached }

        let birthDate = date
        let lat = latitude
        let lon = longitude
        let result = await Task.detached {
            ChartCalculator.calculateChart(date: birthDate, latitude: lat, longitude: lon)
        }.value

        charts[key] = result
        return result
    }

    func weeklyReport(for chart: NatalChart, latitude: Double = 0, longitude: Double = 0) async -> WeeklyTransitReport {
        let weekNum = Calendar.current.component(.weekOfYear, from: Date())
        let year = Calendar.current.component(.year, from: Date())
        let reportKey = "wr_\(Int(chart.ascendantLongitude * 100))_\(year)_\(weekNum)"

        if let cached = reports[reportKey] { return cached }

        let c = chart
        let result = await Task.detached {
            TransitEngine.weeklyReport(for: c)
        }.value

        reports[reportKey] = result
        return result
    }

    func invalidate(date: Date, latitude: Double, longitude: Double) {
        let key = chartKey(date: date, lat: latitude, lon: longitude)
        charts.removeValue(forKey: key)
        reports.removeAll()
    }

    func invalidateAll() {
        charts.removeAll()
        reports.removeAll()
    }
}
