import SwiftUI
import SwiftData

struct ChartDetailView: View {
    @Query(filter: #Predicate<Profile> { $0.isUser }) private var userProfiles: [Profile]
    @State private var showingEdit = false

    private var user: Profile? { userProfiles.first }

    private var chart: NatalChart? {
        guard let user = user else { return nil }
        return ChartCalculator.calculateChart(for: user)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                if let user = user, let chart = chart {
                    VStack(spacing: 24) {
                        // Big three header
                        BigThreeView(chart: chart)

                        // Chart wheel
                        ChartWheelView(chart: chart, size: 340)

                        // All planet placements
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

                        // Natal aspects
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

                        // Interpretations
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

                            // Rising sign
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

                        // Birth info footer
                        VStack(spacing: 4) {
                            Text(user.birthLocationName)
                                .font(.caption)
                            Text(user.birthDate.formatted(date: .long, time: user.hasBirthTime ? .shortened : .omitted))
                                .font(.caption)
                        }
                        .foregroundStyle(.secondary)
                        .padding(.top)
                    }
                    .padding()
                } else {
                    ContentUnavailableView(
                        "No Chart Yet",
                        systemImage: "circle.grid.cross",
                        description: Text("Set up your profile to see your natal chart")
                    )
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
        }
    }
}
