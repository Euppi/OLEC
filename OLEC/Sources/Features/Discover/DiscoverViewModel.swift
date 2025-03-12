import Foundation
import Combine
import CoreLocation

class DiscoverViewModel: ObservableObject {
    @Published var events: [Event] = []
    @Published var filteredEvents: [Event] = []
    @Published var selectedEvent: Event?
    @Published var searchText = ""
    @Published var showFilters = false
    @Published var hasActiveFilters = false
    
    private var locationManager = LocationManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    // Filter States
    @Published var selectedCategories: Set<Event.Category> = []
    @Published var selectedDateRange: ClosedRange<Date>?
    @Published var maxDistance: Double = 10000 // 10km default
    
    init() {
        // Combine search text and filter changes
        Publishers.CombineLatest3(
            $searchText.debounce(for: .milliseconds(300), scheduler: DispatchQueue.main),
            $selectedCategories,
            $selectedDateRange
        )
        .sink { [weak self] searchText, categories, dateRange in
            self?.applyFilters()
        }
        .store(in: &cancellables)
        
        // Listen for location updates
        locationManager.$location
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.refreshEvents()
            }
            .store(in: &cancellables)
    }
    
    func startLocationUpdates() {
        locationManager.startUpdatingLocation()
    }
    
    func refreshEvents() {
        guard let location = locationManager.getCurrentLocation() else { return }
        
        NetworkManager.shared.fetchEvents(location: location, radius: maxDistance)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Error fetching events: \(error)")
                    }
                },
                receiveValue: { [weak self] events in
                    self?.events = events
                    self?.applyFilters()
                }
            )
            .store(in: &cancellables)
    }
    
    private func applyFilters() {
        var filtered = events
        
        // Apply search text filter
        if !searchText.isEmpty {
            filtered = filtered.filter { event in
                event.title.localizedCaseInsensitiveContains(searchText) ||
                event.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply category filter
        if !selectedCategories.isEmpty {
            filtered = filtered.filter { selectedCategories.contains($0.category) }
        }
        
        // Apply date range filter
        if let dateRange = selectedDateRange {
            filtered = filtered.filter { event in
                dateRange.contains(event.startTime)
            }
        }
        
        // Apply distance filter
        if let location = locationManager.getCurrentLocation() {
            filtered = filtered.filter { event in
                guard let distance = locationManager.distance(from: event.location) else { return true }
                return distance <= maxDistance
            }
        }
        
        // Sort by distance and start time
        filtered.sort { event1, event2 in
            if let location = locationManager.getCurrentLocation() {
                let distance1 = locationManager.distance(from: event1.location) ?? Double.infinity
                let distance2 = locationManager.distance(from: event2.location) ?? Double.infinity
                if abs(distance1 - distance2) > 1000 { // If difference is more than 1km
                    return distance1 < distance2
                }
            }
            return event1.startTime < event2.startTime
        }
        
        filteredEvents = filtered
        hasActiveFilters = !selectedCategories.isEmpty || selectedDateRange != nil || searchText.isEmpty
    }
    
    func clearFilters() {
        selectedCategories.removeAll()
        selectedDateRange = nil
        searchText = ""
        hasActiveFilters = false
        applyFilters()
    }
} 