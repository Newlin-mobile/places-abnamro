import Foundation

struct ErrorWrapper: Identifiable {
    let id = UUID()
    let message: String
}

@MainActor
class LocationService: ObservableObject {
    @Published var locations: [Location] = []
    @Published var errorMessage: ErrorWrapper? = nil

    private let url = URL(string: "https://raw.githubusercontent.com/abnamrocoesd/assignment-ios/main/locations.json")!

    func fetchLocations() async {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let locations = try JSONDecoder().decode([Location].self, from: data)
            self.locations = locations
        } catch {
            self.errorMessage = ErrorWrapper(message: "Failed to fetch locations: \(error.localizedDescription)")
        }
    }
}
