import SwiftUI
import SwiftData

@main
struct ElizasAstrologyApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: Profile.self)
    }
}

struct RootView: View {
    @Query(filter: #Predicate<Profile> { $0.isUser }) private var userProfiles: [Profile]

    var body: some View {
        if userProfiles.isEmpty {
            ProfileSetupView(isOnboarding: true)
        } else {
            MainTabView()
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "sparkles")
                }

            ChartDetailView()
                .tabItem {
                    Label("My Chart", systemImage: "circle.grid.cross")
                }

            FriendsListView()
                .tabItem {
                    Label("Friends", systemImage: "person.2")
                }

            CompatibilityView()
                .tabItem {
                    Label("Synastry", systemImage: "heart.circle")
                }
        }
        .tint(.purple)
    }
}
