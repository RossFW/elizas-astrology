import Testing
import Foundation
import SwiftData
@testable import Eliza_s_Astro_App

struct OnboardingFlowTests {

    @Test("Save function creates a user profile and persists it")
    func saveCreatesProfile() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Profile.self, configurations: config)
        let context = ModelContext(container)

        // Simulate what save() does
        let profile = Profile(
            name: "Test User",
            birthDate: Date(),
            birthLatitude: 33.749,
            birthLongitude: -84.388,
            birthLocationName: "Atlanta, GA, United States",
            isUser: true,
            hasBirthTime: true
        )
        context.insert(profile)
        try context.save()

        // Verify the query that RootView uses works
        let freshContext = ModelContext(container)
        let descriptor = FetchDescriptor<Profile>(predicate: #Predicate { $0.isUser })
        let users = try freshContext.fetch(descriptor)

        #expect(users.count == 1, "RootView should find exactly 1 user profile")
        #expect(users.first?.name == "Test User")
    }

    @Test("Chart can be calculated immediately after profile save")
    func chartCalculatesAfterSave() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Profile.self, configurations: config)
        let context = ModelContext(container)

        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        let birthDate = cal.date(from: DateComponents(year: 1995, month: 6, day: 15, hour: 14, minute: 30))!

        let profile = Profile(
            name: "Test",
            birthDate: birthDate,
            birthLatitude: 33.749,
            birthLongitude: -84.388,
            birthLocationName: "Atlanta, GA",
            isUser: true,
            hasBirthTime: true
        )
        context.insert(profile)
        try context.save()

        // Simulate what HomeView does after profile is saved
        let chart = ChartCalculator.calculateChart(
            date: profile.birthDate,
            latitude: profile.birthLatitude,
            longitude: profile.birthLongitude
        )

        #expect(chart.positions.count == 11)
        #expect(chart.sunSign != nil)

        let report = TransitEngine.weeklyReport(for: chart)
        #expect(report.weekStart < report.weekEnd)
    }

    @Test("Chart calculation completes within 2 seconds")
    func chartCalculationPerformance() throws {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        let birthDate = cal.date(from: DateComponents(year: 1995, month: 6, day: 15, hour: 14, minute: 30))!

        let start = Date()

        let chart = ChartCalculator.calculateChart(
            date: birthDate,
            latitude: 33.749,
            longitude: -84.388
        )
        let _ = TransitEngine.weeklyReport(for: chart)

        let elapsed = Date().timeIntervalSince(start)
        #expect(elapsed < 2.0, "Chart + weekly report should complete in under 2 seconds, took \(elapsed)s")
    }

    @Test("Multiple sequential chart calculations do not crash")
    func multipleChartCalculations() {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!

        for year in 1980...2000 {
            let date = cal.date(from: DateComponents(year: year, month: 6, day: 15, hour: 12))!
            let chart = ChartCalculator.calculateChart(date: date, latitude: 40.0, longitude: -74.0)
            #expect(chart.positions.count == 11, "Failed for year \(year)")
        }
    }
}
