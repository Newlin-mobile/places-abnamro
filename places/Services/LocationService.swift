import Foundation

protocol LocationServiceProtocol {
    func fetchLocations() async -> Result<[Location], ErrorWrapper>
}

class LocationService: LocationServiceProtocol {

    private let url = URL(string: "https://raw.githubusercontent.com/abnamrocoesd/assignment-ios/main/locations.json")!

    func fetchLocations() async -> Result<[Location], ErrorWrapper> {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let wrapper = try JSONDecoder().decode(LocationsWrapper.self, from: data)
            return Result.success(wrapper.locations)
        } catch {
            return Result.failure(ErrorWrapper(message: "Failed to fetch locations: \(error.localizedDescription)", underlyingError: error))
        }
    }
}

