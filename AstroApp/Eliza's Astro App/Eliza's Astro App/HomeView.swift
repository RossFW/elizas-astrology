import SwiftUI
import SwiftData

struct HomeView: View {
    @Query(filter: #Predicate<Profile> { $0.isUser }) private var userProfiles: [Profile]

    @State private var chart: NatalChart?
    @State private var report: WeeklyTransitReport?
    @State private var isLoading = true

    private var user: Profile? { userProfiles.first }

    var body: some View {
        NavigationStack {
            ScrollView {
                if let user = user, let chart = chart, let report = report {
                    VStack(spacing: 24) {
                        greetingSection(user: user, chart: chart)
                        bigThreeSection(chart: chart)
                        retrogradeSection(report: report)
                        weeklyTransitsSection(report: report)
                        moonSection(report: report)
                    }
                    .padding()
                } else if isLoading && user != nil {
                    VStack(spacing: 12) {
                        ProgressView()
                            .tint(AstroTheme.gold)
                        Text("Reading the stars...")
                            .font(.subheadline)
                            .foregroundStyle(AstroTheme.dimCream)
                    }
                    .padding(.top, 100)
                }
            }
            .navigationTitle("Home")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .background(AstroTheme.deepNavy)
            .task(id: user?.birthDate) {
                await loadChart()
            }
        }
    }

    private func loadChart() async {
        guard let user = user else {
            isLoading = false
            return
        }
        isLoading = true

        let birthDate = user.birthDate
        let lat = user.birthLatitude
        let lon = user.birthLongitude

        let c = await ChartCache.shared.chart(date: birthDate, latitude: lat, longitude: lon)
        if Task.isCancelled { return }

        let r = await ChartCache.shared.weeklyReport(for: c, latitude: lat, longitude: lon)
        if Task.isCancelled { return }

        chart = c
        report = r
        isLoading = false
    }

    private func greetingSection(user: Profile, chart: NatalChart) -> some View {
        HStack(spacing: 16) {
            Image(chart.sunSign.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 56, height: 56)
            VStack(alignment: .leading, spacing: 4) {
                Text("Hey, \(user.firstName)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(AstroTheme.cream)
                Text(weeklyGreeting())
                    .font(.subheadline)
                    .foregroundStyle(AstroTheme.dimCream)
            }
            Spacer()
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
                                .foregroundStyle(AstroTheme.cream)
                            Spacer()
                            Text("House \(retro.houseInChart)")
                                .font(.caption)
                                .foregroundStyle(AstroTheme.dimCream)
                        }
                        Text(TransitInterpretations.retrogradeInterpretation(retro))
                            .font(.caption)
                            .foregroundStyle(AstroTheme.dimCream)
                    }
                    .astroCard()
                }
            }
        }
    }

    private func weeklyTransitsSection(report: WeeklyTransitReport) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "This Week's Energy", icon: "sparkles")
            Text(weekDateRange(start: report.weekStart, end: report.weekEnd))
                .font(.caption)
                .foregroundStyle(AstroTheme.dimCream)

            if report.topTransits.isEmpty {
                Text("A relatively quiet week in the cosmos for you. Use this time to recharge and reflect.")
                    .font(.subheadline)
                    .foregroundStyle(AstroTheme.dimCream)
                    .astroCard()
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
                .foregroundStyle(AstroTheme.warmGold)
            Text("Moon is currently in \(report.currentMoonSign.name) \(report.currentMoonSign.symbol)")
                .font(.subheadline)
                .foregroundStyle(AstroTheme.cream)
            Spacer()
        }
        .padding()
        .background(AstroTheme.gold.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AstroTheme.gold.opacity(0.2), lineWidth: 0.5)
        )
    }

    private func weekDateRange(start: Date, end: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMM d"
        return "Week of \(fmt.string(from: start)) \u{2013} \(fmt.string(from: end))"
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
