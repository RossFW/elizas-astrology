import SwiftUI
import SwiftData

struct ChartDetailView: View {
    @Query(filter: #Predicate<Profile> { $0.isUser }) private var userProfiles: [Profile]
    @State private var showingEdit = false
    @State private var chart: NatalChart?
    @State private var isLoading = true

    private var user: Profile? { userProfiles.first }

    var body: some View {
        NavigationStack {
            ScrollView {
                if let user = user, let chart = chart {
                    VStack(spacing: 24) {
                        BigThreeView(chart: chart)
                        ChartWheelView(chart: chart, size: 340)
                        planetsSection(chart: chart)
                        aspectsSection(chart: chart)
                        interpretationsSection(chart: chart)
                        birthInfoFooter(user: user)
                    }
                    .padding()
                } else if isLoading && user != nil {
                    ProgressView("Calculating your chart...")
                        .padding(.top, 100)
                }
            }
            .navigationTitle("My Chart")
            .toolbar {
                if user != nil {
                    Button("Edit") { showingEdit = true }
                }
            }
            .sheet(isPresented: $showingEdit) {
                if let user = user {
                    ProfileSetupView(isOnboarding: false, existingProfile: user)
                }
            }
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

        let c = await ChartCache.shared.chart(
            date: user.birthDate,
            latitude: user.birthLatitude,
            longitude: user.birthLongitude
        )
        if Task.isCancelled { return }

        chart = c
        isLoading = false
    }

    private func planetsSection(chart: NatalChart) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title: "Your Planets", icon: "circle.grid.cross")
            ForEach(chart.positions) { pos in
                PlanetRow(position: pos, house: chart.houseForBody(pos.body))
                if pos.body != chart.positions.last?.body {
                    Divider()
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    @ViewBuilder
    private func aspectsSection(chart: NatalChart) -> some View {
        if !chart.aspects.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                SectionHeader(title: "Natal Aspects", icon: "line.diagonal")
                ForEach(chart.aspects.sorted(by: { $0.orb < $1.orb }).prefix(15)) { aspect in
                    AspectRow(aspect: aspect)
                    Divider()
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private func interpretationsSection(chart: NatalChart) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Your Chart Story", icon: "text.book.closed")

            ForEach([CelestialBody.sun, .moon, .mercury, .venus, .mars], id: \.self) { body in
                if let pos = chart.position(for: body) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("\(body.symbol) \(body.name) in \(pos.sign.name)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Text(PlanetSignInterpretations.interpretation(body: body, sign: pos.sign))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("House \(chart.houseForBody(body)): \(HouseDescriptions.description(chart.houseForBody(body)))")
                            .font(.caption2)
                            .foregroundStyle(.purple)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Rising Sign: \(chart.risingSign.symbol) \(chart.risingSign.name)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(SignDescriptions.description(for: chart.risingSign))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("This is the mask you show the world \u{2014} how others first perceive you.")
                    .font(.caption2)
                    .foregroundStyle(.purple)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private func birthInfoFooter(user: Profile) -> some View {
        VStack(spacing: 4) {
            Text(user.birthLocationName)
                .font(.caption)
            Text(user.birthDate.formatted(date: .long, time: user.hasBirthTime ? .shortened : .omitted))
                .font(.caption)
        }
        .foregroundStyle(.secondary)
        .padding(.top)
    }
}
