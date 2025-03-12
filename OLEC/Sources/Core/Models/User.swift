import Foundation

struct User: Identifiable, Codable {
    let id: String
    var email: String
    var displayName: String
    var profileImageURL: URL?
    var interests: [Interest]
    var location: Location?
    var createdAt: Date
    var lastActive: Date
    
    struct Location: Codable {
        let latitude: Double
        let longitude: Double
    }
}

enum Interest: String, Codable, CaseIterable {
    case sports
    case music
    case art
    case food
    case technology
    case outdoors
    case networking
    case nightlife
    case education
    case wellness
    
    var icon: String {
        switch self {
        case .sports: return "figure.run"
        case .music: return "music.note"
        case .art: return "paintpalette"
        case .food: return "fork.knife"
        case .technology: return "laptopcomputer"
        case .outdoors: return "leaf"
        case .networking: return "person.2"
        case .nightlife: return "star"
        case .education: return "book"
        case .wellness: return "heart"
        }
    }
} 