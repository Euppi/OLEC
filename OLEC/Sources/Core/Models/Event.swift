import Foundation

struct Event: Identifiable, Codable {
    let id: String
    let hostId: String
    var title: String
    var description: String
    var category: Category
    var location: Location
    var startTime: Date
    var endTime: Date
    var maxAttendees: Int?
    var currentAttendees: Int
    var imageURL: URL?
    var status: Status
    var createdAt: Date
    var updatedAt: Date
    
    struct Location: Codable {
        let name: String
        let address: String
        let latitude: Double
        let longitude: Double
        let placeId: String?
    }
    
    enum Category: String, Codable, CaseIterable {
        case social
        case sports
        case music
        case art
        case food
        case technology
        case outdoors
        case networking
        case education
        case other
        
        var icon: String {
            switch self {
            case .social: return "person.3"
            case .sports: return "sportscourt"
            case .music: return "music.note.list"
            case .art: return "paintpalette.fill"
            case .food: return "fork.knife.circle"
            case .technology: return "desktopcomputer"
            case .outdoors: return "leaf.circle"
            case .networking: return "network"
            case .education: return "book.circle"
            case .other: return "star.circle"
            }
        }
    }
    
    enum Status: String, Codable {
        case upcoming
        case inProgress
        case completed
        case cancelled
    }
}

// MARK: - Event Extensions
extension Event {
    var isUpcoming: Bool {
        startTime > Date()
    }
    
    var hasAvailableSpots: Bool {
        guard let maxAttendees = maxAttendees else { return true }
        return currentAttendees < maxAttendees
    }
    
    var remainingSpots: Int? {
        guard let maxAttendees = maxAttendees else { return nil }
        return maxAttendees - currentAttendees
    }
    
    var formattedDateRange: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        if Calendar.current.isDate(startTime, inSameDayAs: endTime) {
            dateFormatter.dateStyle = .medium
            let startStr = dateFormatter.string(from: startTime)
            dateFormatter.dateStyle = .none
            let endStr = dateFormatter.string(from: endTime)
            return "\(startStr) \(endStr)"
        } else {
            return "\(dateFormatter.string(from: startTime)) - \(dateFormatter.string(from: endTime))"
        }
    }
} 