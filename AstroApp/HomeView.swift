import SwiftUI
import SwiftData

struct HomeView: View {
    @Query(filter: #Predicate<Profile> { $0.isUser }) private var userProfiles: [Profile]

    private var user: Profile? { userProfiles.first }

    private var chart: NatalChart? {
        guard let user = user else { return nil }
        return ChartCalculator.calculateChart(for: user)
    }

    private var weeklyReport: WeeklyTransitReport? {
        guard let chart = chart else { return nil }
        return TransitEngine.weeklyReport(for: chart)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                if let user = user, let chart = chart, let report = weeklyReport {
                    VStack(spacing: 24) {
                        greetingSection(user: user)
                        bigThreeSection(chart: chart)
                        retrogradeSection(report: report)
                        weeklyTransitsSection(report: report)
                        moonSection(report: report)
                    }
                    .padding()
                } else {
                    ContentUnavailableView(
                        "Set Up Your Profile",
                        systemImage: "person.crop.circle.badge.plus",
                        description: Text("Add your birth info to see your cosmic forecast")
                    )
                }
            }
            .navigationTitle("Home")
            .background(Color(.systemGroupedBackground))
        }
    }

    private func greetingSection(user: Profile) -> some View {
        VStack(spacing: 4) {
            Text("Hey, \(user.firstName)")
                .font(.title)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(weeklyGreeting())
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func bigThreeSection(chart: NatalChart) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Your Big Three", icon: "sun.max")
            BigThreeView(chart: chart)
        }
    }

    @ViewBuilder
    private func retrogradeSection(report: WeeklyTransitReport) -> some View {
        if !report.retrogrades.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(title: "Retrogrades Active", icon: "arrow.uturn.backward.circle")

                ForEach(report.retrogrades) { retro in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            RetrogradeBadge(info: retro)
                            Text("\(retro.body.name) in \(retro.sign.name)")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Spacer()
                            Text("House \(retro.houseInChart)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Text(TransitInterpretations.retrogradeInterpretation(retro))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }

    private func weeklyTransitsSection(report: WeeklyTransitReport) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "This Week's Energy", icon: "sparkles")

            if report.topTransits.isEmpty {
                Text("A relatively quiet week in the cosmos for you. Use this time to recharge and reflect.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                ForEach(report.topTransits) { transit in
                    TransitCard(transit: transit)
                }
            }
        }
    }

    private func moonSection(report: WeeklyTransitReport) -> some View {
        HStack {
            Image(systemName: "moon.fill")
                .foregroundStyle(.purple)
            Text("Moon is currently in \(report.currentMoonSign.name) \(report.currentMoonSign.symbol)")
                .font(.subheadline)
            Spacer()
        }
        .padding()
        .background(Color.purple.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func weeklyGreeting() -> String {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: Date())
        switch weekday {
        case 1: return "Happy Sunday \u{2014} rest and reset"
        case 2: return "Happy Monday \u{2014} fresh week, fresh energy"
        case 3: return "Happy Tuesday \u{2014} building momentum"
        case 4: return "Happy Wednesday \u{2014} midweek magic"
        case 5: return "Happy Thursday \u{2014} Jupiter's day"
        case 6: return "Happy Friday \u{2014} Venus vibes"
        case 7: return "Happy Saturday \u{2014} Saturn's day to recharge"
        default: return "Welcome back"
        }
    }
}
