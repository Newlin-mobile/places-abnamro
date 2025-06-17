import Foundation

protocol LocationServiceProtocol {
    func fetchLocations(completion: @escaping (Result<[Location], Error>) -> Void)
}

@MainActor
class LocationService: ObservableObject, LocationServiceProtocol {
    @Published var locations: [Location] = []
    @Published var errorMessage: ErrorWrapper? = nil

    private let url = URL(string: "https://raw.githubusercontent.com/abnamrocoesd/assignment-ios/main/locations.json")!

    // For VIP Clean
    func fetchLocations(completion: @escaping (Result<[Location], Error>) -> Void) {
        let url = self.url
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let wrapper = try JSONDecoder().decode(LocationsWrapper.self, from: data)
                let locations = wrapper.locations
                DispatchQueue.main.async {
                    completion(.success(locations))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    // Keep async version for backwards compatibility
    func fetchLocations() async {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let wrapper = try JSONDecoder().decode(LocationsWrapper.self, from: data)
            let locations = wrapper.locations
            self.locations = locations
        } catch {
            self.errorMessage = ErrorWrapper(message: "Failed to fetch locations: \(error.localizedDescription)", underlyingError: error)
        }
    }
}

