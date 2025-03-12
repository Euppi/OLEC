import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var appState: AppState
    @State private var currentPage = 0
    
    private let pages = [
        OnboardingPage(
            title: "Discover Events",
            description: "Find exciting events happening around you in real-time",
            imageName: "discover"
        ),
        OnboardingPage(
            title: "Connect",
            description: "Meet new people and join events that match your interests",
            imageName: "connect"
        ),
        OnboardingPage(
            title: "Stay Updated",
            description: "Get personalized recommendations and never miss out",
            imageName: "updates"
        )
    ]
    
    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                    }
                }
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                
                Button(action: {
                    if currentPage < pages.count - 1 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        // Navigate to sign up/login
                        withAnimation {
                            // TODO: Show auth view
                        }
                    }
                }) {
                    Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                
                if currentPage < pages.count - 1 {
                    Button("Skip", action: {
                        // TODO: Show auth view
                    })
                    .foregroundColor(.secondary)
                }
            }
            .padding(.bottom, 30)
        }
    }
}

struct OnboardingPage {
    let title: String
    let description: String
    let imageName: String
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 20) {
            Image(page.imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 300)
            
            Text(page.title)
                .font(.title)
                .bold()
            
            Text(page.description)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
        }
    }
} 