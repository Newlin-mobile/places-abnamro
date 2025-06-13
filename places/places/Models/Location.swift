import Foundation

struct Location: Identifiable, Codable, Equatable {
    let id = UUID()
    let name: String?
    let latitude: Double?
    let longitude: Double?

    enum CodingKeys: String, CodingKey {
        case name
        case latitude = "lat"
        case longitude = "long"
    }
}

struct LocationsWrapper: Codable {
    let locations: [Location]
}
