import Foundation
import MapKit
// Ensure Location model is accessible. If needed, import your app module here.

class PlacesInteractor: PlacesBusinessLogic {
    func selectLocation(_ location: Location) {
        selectedLocation = location
        presenter?.presentSelectedLocation(location)
    }

    func openWikipedia(for location: Location) {
        presenter?.presentOpenWikipedia(for: location)
    }
    
    private var selectedLocation: Location? = nil
    private let service: LocationServiceProtocol
    var presenter: PlacesPresentationLogic?
    
    private(set) var locations: [Location] = []
    
    init(service: LocationServiceProtocol) {
        self.service = service
    }
    
    func fetchLocations() {
        service.fetchLocations { [weak self] result in
            switch result {
            case .success(let locations):
                self?.locations = locations
                self?.presenter?.presentLocations(locations)
            case .failure(let error):
                self?.presenter?.presentError(error)
            }
        }
    }
    
    func addLocation(name: String, center: CLLocationCoordinate2D) {
        let newLoc = Location(name: name, latitude: center.latitude, longitude: center.longitude)
        locations.append(newLoc)
        presenter?.presentLocations(locations)
        presenter?.presentSelectedLocation(newLoc)
        // Optionally, persist via service
    }
    
    func deleteLocations(at offsets: IndexSet) {
        locations.remove(atOffsets: offsets)
        presenter?.presentLocations(locations)
        presenter?.presentSelectedLocation(nil)
        // Optionally, persist via service
    }
}
