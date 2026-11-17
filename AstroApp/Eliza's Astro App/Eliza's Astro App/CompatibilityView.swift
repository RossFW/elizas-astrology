import SwiftUI
import SwiftData

struct CompatibilityView: View {
    @Query private var allProfiles: [Profile]
    @State private var person1: Profile?
    @State private var person2: Profile?
    @State private var report: SynastryReport?
    @State private var chart1: NatalChart?
    @State private var chart2: NatalChart?
    @State private var isCalculating = false

    private var bothSelected: Bool {
        person1 != nil && person2 != nil &&
        person1?.persistentModelID != person2?.persistentModelID
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    personSelectors

                    if isCalculating {
                        ProgressView("Comparing charts...")
                            .padding(.top, 40)
                    } else if let report = report, let c1 = chart1, let c2 = chart2 {
                        HarmonyGauge(value: report.overallHarmony)

                        Text(CompatibilityInterpretations.overallMessage(harmony: report.overallHarmony))
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                        if let p1 = person1, let p2 = person2 {
                            bigThreeComparison(p1: p1, p2: p2, c1: c1, c2: c2)
                        }

                        if !report.harmonious.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                SectionHeader(title: "What Flows", icon: "sparkle")
                                ForEach(report.harmonious.prefix(8)) { aspect in
                                    aspectCard(aspect: aspect, isHarmonious: true)
                                }
                            }
                        }

                        if !report.challenging.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                SectionHeader(title: "Growth Edges", icon: "bolt.fill")
                                ForEach(report.challenging.prefix(8)) { aspect in
                                    aspectCard(aspect: aspect, isHarmonious: false)
                                }
                            }
                        }
                    } else if person1 != nil && person2 != nil &&
                              person1?.persistentModelID == person2?.persistentModelID {
                        Text("Pick two different people to compare")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.top, 40)
                    } else if allProfiles.count < 2 {
                        ContentUnavailableView(
                            "Need Two Profiles",
                            systemImage: "person.2",
                            description: Text("Add at least one friend to explore compatibility")
                        )
                    } else {
                        Text("Select two people above to see their cosmic compatibility")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.top, 40)
                    }
                }
                .padding()
            }
            .navigationTitle("Compatibility")
            .onChange(of: person1?.persistentModelID) { _, _ in
                Task { await calculateIfReady() }
            }
            .onChange(of: person2?.persistentModelID) { _, _ in
                Task { await calculateIfReady() }
            }
        }
    }

    private var personSelectors: some View {
        VStack(spacing: 12) {
            personPicker(label: "Person 1", selection: $person1)
            Image(systemName: "heart.fill")
                .foregroundStyle(.pink)
                .font(.title2)
            personPicker(label: "Person 2", selection: $person2)
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func calculateIfReady() async {
        guard bothSelected, let p1 = person1, let p2 = person2 else {
            report = nil
            chart1 = nil
            chart2 = nil
            return
        }

        isCalculating = true

        let c1 = await ChartCache.shared.chart(
            date: p1.birthDate, latitude: p1.birthLatitude, longitude: p1.birthLongitude
        )
        let c2 = await ChartCache.shared.chart(
            date: p2.birthDate, latitude: p2.birthLatitude, longitude: p2.birthLongitude
        )

        let r = SynastryCalculator.compare(chart1: c1, chart2: c2)

        chart1 = c1
        chart2 = c2
        report = r
        isCalculating = false
    }

    private func personPicker(label: String, selection: Binding<Profile?>) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(width: 70, alignment: .leading)

            Picker(label, selection: selection) {
                Text("Select...").tag(nil as Profile?)
                ForEach(allProfiles) { profile in
                    Text(profile.name).tag(profile as Profile?)
                }
            }
            .pickerStyle(.menu)
            .tint(.purple)
        }
    }

    private func bigThreeComparison(p1: Profile, p2: Profile, c1: NatalChart, c2: NatalChart) -> some View {
        VStack(spacing: 12) {
            SectionHeader(title: "Big Three Comparison", icon: "person.2.fill")
            HStack {
                Text("")
                    .frame(width: 60)
                Text(p1.firstName)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                Text(p2.firstName)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
            }
            comparisonRow(label: "Sun", sign1: c1.sunSign, sign2: c2.sunSign)
            comparisonRow(label: "Moon", sign1: c1.moonSign, sign2: c2.moonSign)
            comparisonRow(label: "Rising", sign1: c1.risingSign, sign2: c2.risingSign)
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func comparisonRow(label: String, sign1: ZodiacSign, sign2: ZodiacSign) -> some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 60, alignment: .leading)
            Text("\(sign1.symbol) \(sign1.name)")
                .font(.caption)
                .frame(maxWidth: .infinity)
            Text("\(sign2.symbol) \(sign2.name)")
                .font(.caption)
                .frame(maxWidth: .infinity)
        }
    }

    private func aspectCard(aspect: ChartAspect, isHarmonious: Bool) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("\(aspect.body1.symbol) \(aspect.type.symbol) \(aspect.body2.symbol)")
                    .font(.subheadline)
                Spacer()
                Text(aspect.type.name)
                    .font(.caption)
                    .foregroundStyle(isHarmonious ? .green : .orange)
            }
            Text(CompatibilityInterpretations.aspectMeaning(aspect))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
