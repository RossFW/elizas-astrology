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
                    VStack(spacing: 16) {
                        Image(systemName: "person.2.slash")
                            .font(.largeTitle)
                            .foregroundStyle(AstroTheme.dimCream)
                        Text("No Friends Yet")
                            .font(.headline)
                            .foregroundStyle(AstroTheme.cream)
                        Text("Add friends and loved ones to see how the stars affect them too")
                            .font(.subheadline)
                            .foregroundStyle(AstroTheme.dimCream)
                            .multilineTextAlignment(.center)
                    }
                    .padding(40)
                } else {
                    List(friends) { friend in
                        NavigationLink(destination: FriendDetailView(profile: friend)) {
                            FriendRow(profile: friend)
                        }
                        .listRowBackground(AstroTheme.cardBackground)
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Friends")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .background(AstroTheme.deepNavy)
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
            if let chart = chart {
                Image(chart.sunSign.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
            } else {
                Circle()
                    .fill(AstroTheme.cardBorder)
                    .frame(width: 40, height: 40)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(profile.name)
                    .font(.headline)
                    .foregroundStyle(AstroTheme.cream)
                if let chart = chart {
                    Text("\(chart.sunSign.symbol) \(chart.sunSign.name) \u{2022} \(chart.moonSign.symbol) \(chart.moonSign.name) \u{2022} \(chart.risingSign.symbol) \(chart.risingSign.name)")
                        .font(.caption)
                        .foregroundStyle(AstroTheme.dimCream)
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
                            .foregroundStyle(AstroTheme.cream)
                        Text(profile.birthLocationName)
                            .font(.caption)
                            .foregroundStyle(AstroTheme.dimCream)
                        BigThreeView(chart: chart)
                    }

                    ChartWheelView(chart: chart, size: 320)

                    VStack(alignment: .leading, spacing: 8) {
                        SectionHeader(title: "Planet Placements", icon: "circle.grid.cross")
                        ForEach(chart.positions) { pos in
                            PlanetRow(position: pos, house: chart.houseForBody(pos.body))
                            if pos.body != chart.positions.last?.body {
                                Divider().overlay(AstroTheme.cardBorder)
                            }
                        }
                    }
                    .astroCard()

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
                VStack(spacing: 12) {
                    ProgressView()
                        .tint(AstroTheme.gold)
                    Text("Calculating chart...")
                        .font(.subheadline)
                        .foregroundStyle(AstroTheme.dimCream)
                }
                .padding(.top, 100)
            }
        }
        .background(AstroTheme.deepNavy)
        .navigationTitle(profile.firstName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
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
                .foregroundStyle(AstroTheme.cream)
            Text(text)
                .font(.caption)
                .foregroundStyle(AstroTheme.dimCream)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AstroTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
