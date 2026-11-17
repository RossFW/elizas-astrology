import SwiftUI
import SwiftData

// MARK: - Friends List

struct FriendsListView: View {
    @Query(filter: #Predicate<Profile> { !$0.isUser },
           sort: \Profile.name) private var friends: [Profile]
    @State private var showingAddFriend = false

    var body: some View {
        NavigationStack {
            Group {
                if friends.isEmpty {
                    ContentUnavailableView(
                        "No Friends Yet",
                        systemImage: "person.2.slash",
                        description: Text("Add friends and loved ones to see how the stars affect them too")
                    )
                } else {
                    List(friends) { friend in
                        NavigationLink(destination: FriendDetailView(profile: friend)) {
                            FriendRow(profile: friend)
                        }
                    }
                }
            }
            .navigationTitle("Friends")
            .toolbar {
                Button {
                    showingAddFriend = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showingAddFriend) {
                ProfileSetupView(isOnboarding: false)
            }
        }
    }
}

struct FriendRow: View {
    let profile: Profile
    @State private var chart: NatalChart?

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill((chart?.sunSign.element.color ?? .gray).opacity(0.2))
                    .frame(width: 44, height: 44)
                Text(chart?.sunSign.symbol ?? "...")
                    .font(.title3)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(profile.name)
                    .font(.headline)
                if let chart = chart {
                    Text("\(chart.sunSign.symbol) \(chart.sunSign.name) \u{2022} \(chart.moonSign.symbol) \(chart.moonSign.name) \u{2022} \(chart.risingSign.symbol) \(chart.risingSign.name)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
        .task(id: profile.birthDate) {
            chart = await ChartCache.shared.chart(
                date: profile.birthDate,
                latitude: profile.birthLatitude,
                longitude: profile.birthLongitude
            )
        }
    }
}

// MARK: - Friend Detail

struct FriendDetailView: View {
    let profile: Profile
    @State private var showingEdit = false
    @State private var chart: NatalChart?
    @State private var transits: [Transit] = []
    @State private var isLoading = true

    var body: some View {
        ScrollView {
            if let chart = chart {
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Text(profile.name)
                            .font(.title)
                            .fontWeight(.bold)
                        Text(profile.birthLocationName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        BigThreeView(chart: chart)
                    }

                    ChartWheelView(chart: chart, size: 320)

                    VStack(alignment: .leading, spacing: 8) {
                        SectionHeader(title: "Planet Placements", icon: "circle.grid.cross")
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

                    if !transits.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(title: "Current Transits", icon: "sparkles")
                            ForEach(Array(transits.prefix(5))) { transit in
                                TransitCard(transit: transit)
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "Chart Insights", icon: "text.book.closed")

                        if let sunPos = chart.position(for: .sun) {
                            interpretationBlock(
                                title: "\(CelestialBody.sun.symbol) Sun in \(sunPos.sign.name)",
                                text: PlanetSignInterpretations.interpretation(body: .sun, sign: sunPos.sign)
                            )
                        }

                        if let moonPos = chart.position(for: .moon) {
                            interpretationBlock(
                                title: "\(CelestialBody.moon.symbol) Moon in \(moonPos.sign.name)",
                                text: PlanetSignInterpretations.interpretation(body: .moon, sign: moonPos.sign)
                            )
                        }

                        interpretationBlock(
                            title: "Rising \(chart.risingSign.symbol) \(chart.risingSign.name)",
                            text: SignDescriptions.description(for: chart.risingSign)
                        )
                    }
                }
                .padding()
            } else if isLoading {
                ProgressView("Calculating chart...")
                    .padding(.top, 100)
            }
        }
        .navigationTitle(profile.firstName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button("Edit") { showingEdit = true }
        }
        .sheet(isPresented: $showingEdit) {
            ProfileSetupView(isOnboarding: false, existingProfile: profile)
        }
        .task(id: profile.birthDate) {
            await loadChart()
        }
    }

    private func loadChart() async {
        isLoading = true

        let c = await ChartCache.shared.chart(
            date: profile.birthDate,
            latitude: profile.birthLatitude,
            longitude: profile.birthLongitude
        )
        if Task.isCancelled { return }

        let t = await Task.detached {
            TransitEngine.currentTransits(for: c)
                .sorted { $0.significance > $1.significance }
        }.value
        if Task.isCancelled { return }

        chart = c
        transits = t
        isLoading = false
    }

    private func interpretationBlock(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
            Text(text)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
