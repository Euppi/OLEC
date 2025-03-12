import SwiftUI
import MapKit

struct EventDetailView: View {
    let event: Event
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: EventDetailViewModel
    
    init(event: Event) {
        self.event = event
        _viewModel = StateObject(wrappedValue: EventDetailViewModel(event: event))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Event Image
                if let imageURL = event.imageURL {
                    AsyncImage(url: imageURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color.gray.opacity(0.2)
                    }
                    .frame(height: 250)
                }
                
                VStack(alignment: .leading, spacing: 20) {
                    // Title and Host
                    VStack(alignment: .leading, spacing: 8) {
                        Text(event.title)
                            .font(.title)
                            .bold()
                        
                        HStack {
                            AsyncImage(url: viewModel.hostProfileImageURL) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Image(systemName: "person.circle.fill")
                            }
                            .frame(width: 24, height: 24)
                            .clipShape(Circle())
                            
                            Text("Hosted by \(viewModel.hostName)")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Date and Time
                    HStack {
                        Image(systemName: "calendar")
                        Text(event.formattedDateRange)
                    }
                    .foregroundColor(.primary)
                    
                    // Location
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "mappin.circle.fill")
                            Text(event.location.name)
                        }
                        Text(event.location.address)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Map Preview
                    Map(coordinateRegion: .constant(MKCoordinateRegion(
                        center: CLLocationCoordinate2D(
                            latitude: event.location.latitude,
                            longitude: event.location.longitude
                        ),
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    )))
                    .frame(height: 150)
                    .cornerRadius(12)
                    
                    // Description
                    Text("About")
                        .font(.headline)
                    Text(event.description)
                        .foregroundColor(.secondary)
                    
                    // Attendees
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Attendees")
                            .font(.headline)
                        
                        HStack {
                            ForEach(viewModel.attendees.prefix(5)) { attendee in
                                AsyncImage(url: attendee.profileImageURL) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    Image(systemName: "person.circle.fill")
                                }
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                            }
                            
                            if viewModel.attendees.count > 5 {
                                Text("+\(viewModel.attendees.count - 5)")
                                    .font(.caption)
                                    .padding(8)
                                    .background(Color(.systemGray5))
                                    .clipShape(Circle())
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .overlay(alignment: .bottom) {
            // RSVP Button
            VStack(spacing: 8) {
                if let spots = event.remainingSpots {
                    Text("\(spots) spots remaining")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Button(action: viewModel.toggleRSVP) {
                    HStack {
                        Image(systemName: viewModel.isAttending ? "checkmark.circle.fill" : "plus.circle.fill")
                        Text(viewModel.isAttending ? "Attending" : "RSVP")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.isAttending ? Color.green : Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(!event.hasAvailableSpots && !viewModel.isAttending)
            }
            .padding()
            .background(
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .ignoresSafeArea()
            )
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: viewModel.shareEvent) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
    }
}

class EventDetailViewModel: ObservableObject {
    @Published var hostName = ""
    @Published var hostProfileImageURL: URL?
    @Published var attendees: [User] = []
    @Published var isAttending = false
    
    private let event: Event
    private var cancellables = Set<AnyCancellable>()
    
    init(event: Event) {
        self.event = event
        loadEventDetails()
    }
    
    private func loadEventDetails() {
        // Load host details
        NetworkManager.shared.fetchUserProfile(event.hostId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] host in
                    self?.hostName = host.displayName
                    self?.hostProfileImageURL = host.profileImageURL
                }
            )
            .store(in: &cancellables)
            
        // TODO: Load attendees and check current user's RSVP status
    }
    
    func toggleRSVP() {
        // TODO: Implement RSVP functionality
        isAttending.toggle()
    }
    
    func shareEvent() {
        // TODO: Implement share functionality
    }
} 