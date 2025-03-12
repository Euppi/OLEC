import Foundation
import Combine

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case decodingError
    case serverError(String)
    case unauthorized
    case unknown
}

class NetworkManager {
    static let shared = NetworkManager()
    private let baseURL = "https://api.olec.app" // Replace with your actual API base URL
    private var cancellables = Set<AnyCancellable>()
    
    private init() {}
    
    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod = .get,
        parameters: [String: Any]? = nil
    ) -> AnyPublisher<T, NetworkError> {
        guard let url = URL(string: baseURL + endpoint) else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let parameters = parameters {
            request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.invalidResponse
                }
                
                switch httpResponse.statusCode {
                case 200...299:
                    return data
                case 401:
                    throw NetworkError.unauthorized
                default:
                    throw NetworkError.serverError("Status code: \(httpResponse.statusCode)")
                }
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error in
                switch error {
                case is DecodingError:
                    return NetworkError.decodingError
                case let networkError as NetworkError:
                    return networkError
                default:
                    return NetworkError.unknown
                }
            }
            .eraseToAnyPublisher()
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

// MARK: - API Endpoints
extension NetworkManager {
    func fetchEvents(location: User.Location, radius: Double) -> AnyPublisher<[Event], NetworkError> {
        let parameters: [String: Any] = [
            "latitude": location.latitude,
            "longitude": location.longitude,
            "radius": radius
        ]
        return request(endpoint: "/events/nearby", method: .get, parameters: parameters)
    }
    
    func createEvent(_ event: Event) -> AnyPublisher<Event, NetworkError> {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(event),
              let parameters = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return Fail(error: NetworkError.decodingError).eraseToAnyPublisher()
        }
        return request(endpoint: "/events", method: .post, parameters: parameters)
    }
    
    func updateEvent(_ event: Event) -> AnyPublisher<Event, NetworkError> {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(event),
              let parameters = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return Fail(error: NetworkError.decodingError).eraseToAnyPublisher()
        }
        return request(endpoint: "/events/\(event.id)", method: .put, parameters: parameters)
    }
    
    func fetchUserProfile(_ userId: String) -> AnyPublisher<User, NetworkError> {
        request(endpoint: "/users/\(userId)")
    }
    
    func updateUserProfile(_ user: User) -> AnyPublisher<User, NetworkError> {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(user),
              let parameters = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return Fail(error: NetworkError.decodingError).eraseToAnyPublisher()
        }
        return request(endpoint: "/users/\(user.id)", method: .put, parameters: parameters)
    }
} 