import SwiftUI
import SwiftData
import MapKit
import UIKit

struct ProfileSetupView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var isOnboarding: Bool = false
    var existingProfile: Profile?
    var onOnboardingComplete: (() -> Void)?

    @State private var name = ""
    @State private var birthDate = Calendar.current.date(from: DateComponents(year: 1995, month: 6, day: 15))!
    @State private var hasBirthTime = true
    @State private var locationQuery = ""
    @State private var selectedLocation: LocationResult?
    @State private var searchResults: [LocationResult] = []
    @State private var isSearching = false
    @State private var isSaving = false
    @State private var saveError: String?

    struct LocationResult: Identifiable, Hashable {
        let id = UUID()
        let name: String
        let latitude: Double
        let longitude: Double
    }

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && selectedLocation != nil && !isSaving
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
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
                        if let loc = selectedLocation {
                            HStack {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundStyle(.green)
                                Text(loc.name)
                                Spacer()
                                Button("Change") {
                                    selectedLocation = nil
                                    locationQuery = ""
                                    searchResults = []
                                }
                                .font(.caption)
                            }
                        } else {
                            TextField("Search city...", text: $locationQuery)
                                .autocorrectionDisabled()
                                .onSubmit {
                                    searchLocation(locationQuery)
                                }
                                .onChange(of: locationQuery) { _, newValue in
                                    if newValue.count >= 2 {
                                        searchLocation(newValue)
                                    } else {
                                        searchResults = []
                                    }
                                }

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
                                    }
                                }
                            }
                        }
                    }
                }

                Button(action: save) {
                    Group {
                        if isSaving {
                            HStack(spacing: 8) {
                                ProgressView()
                                    .tint(.white)
                                Text("Calculating your chart...")
                            }
                        } else {
                            Text(isOnboarding ? "See My Chart" : "Save")
                                .fontWeight(.bold)
                        }
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(canSave ? Color.purple : Color.gray)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
                .disabled(!canSave)
            }
            .navigationTitle(isOnboarding ? "Your Birth Chart" : (existingProfile != nil ? "Edit Profile" : "New Profile"))
            .alert("Save Error", isPresented: Binding(
                get: { saveError != nil },
                set: { if !$0 { saveError = nil } }
            )) {
                Button("OK") { saveError = nil }
            } message: {
                Text(saveError ?? "Unknown error")
            }
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
        // Haptic feedback so user knows tap registered
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()

        guard let location = selectedLocation else {
            generator.notificationOccurred(.error)
            saveError = "No location selected"
            return
        }
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            generator.notificationOccurred(.error)
            saveError = "Name is empty"
            return
        }

        generator.notificationOccurred(.success)
        isSaving = true
        saveError = nil

        if !hasBirthTime {
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

        do {
            try modelContext.save()
        } catch {
            saveError = "Save failed: \(error.localizedDescription)"
            isSaving = false
            return
        }

        if isOnboarding {
            onOnboardingComplete?()
        } else {
            isSaving = false
            dismiss()
        }
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

        let search = MKLocalSearch(request: request)
        Task {
            let response = try? await search.start()
            isSearching = false
            guard let response else {
                searchResults = []
                return
            }
            searchResults = response.mapItems.prefix(5).map { item in
                let parts = [item.placemark.locality, item.placemark.administrativeArea, item.placemark.country]
                var seen = Set<String>()
                let uniqueParts = parts.compactMap { $0 }.filter { seen.insert($0).inserted }
                return LocationResult(
                    name: uniqueParts.joined(separator: ", "),
                    latitude: item.placemark.coordinate.latitude,
                    longitude: item.placemark.coordinate.longitude
                )
            }
        }
    }
}
