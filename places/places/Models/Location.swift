import Foundation

public struct Location: Identifiable, Codable, Equatable {
    public let id = UUID()
    let name: String?
    let latitude: Double?
    let longitude: Double?

    enum CodingKeys: String, CodingKey {
        case name
        case latitude = "lat"
        case longitude = "long"
    }
}

public struct LocationsWrapper: Codable {
    let locations: [Location]
}
