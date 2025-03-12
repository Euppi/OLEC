import SwiftUI
import MapKit

struct DiscoverView: View {
    @StateObject private var viewModel = DiscoverViewModel()
    @State private var selectedTab = 0
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search and Filter Bar
                searchAndFilterBar
                
                // Tab Selector
                Picker("View", selection: $selectedTab) {
                    Image(systemName: "map").tag(0)
                    Image(systemName: "list.bullet").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Content
                TabView(selection: $selectedTab) {
                    mapView
                        .tag(0)
                    
                    eventListView
                        .tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .navigationTitle("Discover")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: viewModel.refreshEvents) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
        .onAppear {
            LocationManager.shared.requestLocationPermission()
            viewModel.startLocationUpdates()
        }
    }
    
    private var searchAndFilterBar: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search events", text: $viewModel.searchText)
            }
            .padding(8)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            
            Button(action: { viewModel.showFilters.toggle() }) {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .foregroundColor(viewModel.hasActiveFilters ? .accentColor : .primary)
            }
        }
        .padding()
    }
    
    private var mapView: some View {
        Map(coordinateRegion: $region,
            showsUserLocation: true,
            annotationItems: viewModel.filteredEvents) { event in
            MapAnnotation(coordinate: CLLocationCoordinate2D(
                latitude: event.location.latitude,
                longitude: event.location.longitude
            )) {
                EventMapMarker(event: event) {
                    viewModel.selectedEvent = event
                }
            }
        }
        .sheet(item: $viewModel.selectedEvent) { event in
            EventDetailView(event: event)
        }
    }
    
    private var eventListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.filteredEvents) { event in
                    EventCardView(event: event)
                        .onTapGesture {
                            viewModel.selectedEvent = event
                        }
                }
            }
            .padding()
        }
    }
}

struct EventMapMarker: View {
    let event: Event
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                Image(systemName: event.category.icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(Color.accentColor)
                    .clipShape(Circle())
                
                Image(systemName: "triangle.fill")
                    .font(.system(size: 10))
                    .foregroundColor(.accentColor)
                    .offset(y: -3)
            }
        }
    }
}

struct EventCardView: View {
    let event: Event
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Event Image
            if let imageURL = event.imageURL {
                AsyncImage(url: imageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                .frame(height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            // Event Details
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.headline)
                
                Text(event.formattedDateRange)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Image(systemName: event.category.icon)
                    Text(event.category.rawValue.capitalized)
                    
                    if let spots = event.remainingSpots {
                        Spacer()
                        Text("\(spots) spots left")
                            .foregroundColor(.secondary)
                    }
                }
                .font(.caption)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
} 