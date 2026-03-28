import SwiftUI
import SwiftData
import MapKit

struct ProfileSetupView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var isOnboarding: Bool = false
    var existingProfile: Profile?

    @State private var name = ""
    @State private var birthDate = Calendar.current.date(from: DateComponents(year: 1995, month: 6, day: 15))!
    @State private var hasBirthTime = true
    @State private var locationQuery = ""
    @State private var selectedLocation: LocationResult?
    @State private var searchResults: [LocationResult] = []
    @State private var isSearching = false

    struct LocationResult: Identifiable, Hashable {
        let id = UUID()
        let name: String
        let latitude: Double
        let longitude: Double
    }

    var body: some View {
        NavigationStack {
            Form {
                if isOnboarding {
                    Section {
                        VStack(spacing: 8) {
                            Text("Welcome to the cosmos")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Enter your birth details to calculate your natal chart. The more precise, the more accurate your readings.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .listRowBackground(Color.clear)
                    }
                }

                Section("Name") {
                    TextField("Your name", text: $name)
                }

                Section("Birth Date & Time") {
                    DatePicker(
                        "Date and time",
                        selection: $birthDate,
                        in: ...Date.now,
                        displayedComponents: hasBirthTime ? [.date, .hourAndMinute] : [.date]
                    )

                    Toggle("I know my exact birth time", isOn: $hasBirthTime)

                    if !hasBirthTime {
                        Text("Without a birth time, your Rising sign and house placements will be less accurate. Check your birth certificate if you can!")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Birth Location") {
                    TextField("Search city...", text: $locationQuery)
                        .onChange(of: locationQuery) { _, newValue in
                            searchLocation(newValue)
                        }
                        .autocorrectionDisabled()

                    if isSearching {
                        HStack {
                            ProgressView()
                            Text("Searching...")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    ForEach(searchResults) { result in
                        Button {
                            selectedLocation = result
                            locationQuery = result.name
                            searchResults = []
                        } label: {
                            HStack {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundStyle(.purple)
                                Text(result.name)
                                    .foregroundStyle(.primary)
                                Spacer()
                                if selectedLocation == result {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                }
                            }
                        }
                    }

                    if let loc = selectedLocation {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                            Text(loc.name)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section {
                    Button(action: save) {
                        Text(isOnboarding ? "See My Chart" : "Save")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(name.isEmpty || selectedLocation == nil)
                }
            }
            .navigationTitle(isOnboarding ? "Your Birth Chart" : (existingProfile != nil ? "Edit Profile" : "New Profile"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !isOnboarding {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                }
            }
            .onAppear {
                if let profile = existingProfile {
                    name = profile.name
                    birthDate = profile.birthDate
                    hasBirthTime = profile.hasBirthTime
                    locationQuery = profile.birthLocationName
                    selectedLocation = LocationResult(
                        name: profile.birthLocationName,
                        latitude: profile.birthLatitude,
                        longitude: profile.birthLongitude
                    )
                }
            }
        }
    }

    private func save() {
        guard let location = selectedLocation else { return }

        if !hasBirthTime {
            // Set to noon if no birth time known
            var cal = Calendar.current
            cal.timeZone = .gmt
            let comps = cal.dateComponents([.year, .month, .day], from: birthDate)
            if let noon = cal.date(from: DateComponents(
                year: comps.year, month: comps.month, day: comps.day, hour: 12
            )) {
                birthDate = noon
            }
        }

        if let existing = existingProfile {
            existing.name = name
            existing.birthDate = birthDate
            existing.birthLatitude = location.latitude
            existing.birthLongitude = location.longitude
            existing.birthLocationName = location.name
            existing.hasBirthTime = hasBirthTime
        } else {
            let profile = Profile(
                name: name,
                birthDate: birthDate,
                birthLatitude: location.latitude,
                birthLongitude: location.longitude,
                birthLocationName: location.name,
                isUser: isOnboarding,
                hasBirthTime: hasBirthTime
            )
            modelContext.insert(profile)
        }

        dismiss()
    }

    private func searchLocation(_ query: String) {
        guard query.count >= 2 else {
            searchResults = []
            return
        }

        isSearching = true
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = .address

        MKLocalSearch(request: request).start { response, error in
            isSearching = false
            guard let response = response else {
                searchResults = []
                return
            }
            searchResults = response.mapItems.prefix(5).map { item in
                LocationResult(
                    name: [item.name, item.placemark.locality, item.placemark.administrativeArea, item.placemark.country]
                        .compactMap { $0 }
                        .joined(separator: ", "),
                    latitude: item.placemark.coordinate.latitude,
                    longitude: item.placemark.coordinate.longitude
                )
            }
        }
    }
}
