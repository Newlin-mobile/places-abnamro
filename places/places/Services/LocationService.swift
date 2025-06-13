import Foundation

@MainActor
class LocationService: ObservableObject {
    @Published var locations: [Location] = []
    @Published var errorMessage: ErrorWrapper? = nil

    private let url = URL(string: "https://raw.githubusercontent.com/abnamrocoesd/assignment-ios/main/locations.json")!

    func fetchLocations() async {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let wrapper = try JSONDecoder().decode(LocationsWrapper.self, from: data)
            let locations = wrapper.locations.filter { $0.name != nil }
            self.locations = locations
        } catch {
            self.errorMessage = ErrorWrapper(message: "Failed to fetch locations: \(error.localizedDescription)", underlyingError: error)
        }
    }
}
