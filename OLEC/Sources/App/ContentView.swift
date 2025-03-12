import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        Group {
            if !appState.isAuthenticated {
                OnboardingView()
            } else {
                TabView(selection: $appState.selectedTab) {
                    DiscoverView()
                        .tabItem {
                            Label("Discover", systemImage: "map")
                        }
                        .tag(AppState.Tab.discover)
                    
                    EventsView()
                        .tabItem {
                            Label("Events", systemImage: "calendar")
                        }
                        .tag(AppState.Tab.events)
                    
                    ChatView()
                        .tabItem {
                            Label("Chat", systemImage: "message")
                        }
                        .tag(AppState.Tab.chat)
                    
                    ProfileView()
                        .tabItem {
                            Label("Profile", systemImage: "person")
                        }
                        .tag(AppState.Tab.profile)
                }
            }
        }
    }
} 