import Foundation
import MapKit
// Ensure Location and protocol types are accessible. If needed, import your app module here.
import MapKit

struct PlacesViewModel {
    struct Locations {
        let locations: [Location]
    }
    struct Error {
        let message: String
    }
}
