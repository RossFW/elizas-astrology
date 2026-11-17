import Testing
import Foundation
import SwiftData
@testable import Eliza_s_Astro_App

struct ProfilePersistenceTests {

    @Test("Profile persists after explicit save")
    func profilePersistsAfterSave() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Profile.self, configurations: config)
        let context = ModelContext(container)

        let profile = Profile(
            name: "Test User",
            birthDate: Date(),
            birthLatitude: 40.7128,
            birthLongitude: -74.0060,
            birthLocationName: "New York, NY",
            isUser: true,
            hasBirthTime: true
        )

        context.insert(profile)
        try context.save()

        let freshContext = ModelContext(container)
        let descriptor = FetchDescriptor<Profile>(predicate: #Predicate { $0.isUser })
        let fetched = try freshContext.fetch(descriptor)

        #expect(fetched.count == 1)
        #expect(fetched.first?.name == "Test User")
    }

    @Test("Profile field integrity is preserved through save/fetch cycle")
    func profileFieldIntegrity() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Profile.self, configurations: config)
        let context = ModelContext(container)

        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        let birthDate = cal.date(from: DateComponents(year: 1995, month: 6, day: 15, hour: 14, minute: 30))!

        let profile = Profile(
            name: "Eliza Cosmos",
            birthDate: birthDate,
            birthLatitude: 34.0522,
            birthLongitude: -118.2437,
            birthLocationName: "Los Angeles, CA, United States",
            isUser: true,
            hasBirthTime: true
        )

        context.insert(profile)
        try context.save()

        let freshContext = ModelContext(container)
        let descriptor = FetchDescriptor<Profile>(predicate: #Predicate { $0.isUser })
        let fetched = try freshContext.fetch(descriptor)

        let p = try #require(fetched.first)
        #expect(p.name == "Eliza Cosmos")
        #expect(p.birthLatitude == 34.0522)
        #expect(p.birthLongitude == -118.2437)
        #expect(p.birthLocationName == "Los Angeles, CA, United States")
        #expect(p.hasBirthTime == true)
        #expect(p.isUser == true)
    }

    @Test("Non-user profiles are not returned by isUser predicate")
    func nonUserProfileFiltering() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Profile.self, configurations: config)
        let context = ModelContext(container)

        let userProfile = Profile(
            name: "Main User",
            birthDate: Date(),
            birthLatitude: 0,
            birthLongitude: 0,
            birthLocationName: "Somewhere",
            isUser: true
        )
        let friendProfile = Profile(
            name: "Friend",
            birthDate: Date(),
            birthLatitude: 0,
            birthLongitude: 0,
            birthLocationName: "Elsewhere",
            isUser: false
        )

        context.insert(userProfile)
        context.insert(friendProfile)
        try context.save()

        let freshContext = ModelContext(container)
        let userDescriptor = FetchDescriptor<Profile>(predicate: #Predicate { $0.isUser })
        let users = try freshContext.fetch(userDescriptor)

        let friendDescriptor = FetchDescriptor<Profile>(predicate: #Predicate { !$0.isUser })
        let friends = try freshContext.fetch(friendDescriptor)

        #expect(users.count == 1)
        #expect(users.first?.name == "Main User")
        #expect(friends.count == 1)
        #expect(friends.first?.name == "Friend")
    }

    @Test("Profile firstName computed property works correctly")
    func profileFirstName() {
        let profile = Profile(
            name: "Eliza Kim",
            birthDate: Date(),
            birthLatitude: 0,
            birthLongitude: 0,
            birthLocationName: "Test"
        )
        #expect(profile.firstName == "Eliza")

        let single = Profile(
            name: "Eliza",
            birthDate: Date(),
            birthLatitude: 0,
            birthLongitude: 0,
            birthLocationName: "Test"
        )
        #expect(single.firstName == "Eliza")
    }
}
