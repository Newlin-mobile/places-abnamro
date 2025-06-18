import Foundation
import MapKit

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
        Task {
            switch await service.fetchLocations() {
            case .success(let newLocations):
                locations = newLocations
                presenter?.presentLocations(newLocations)
            case .failure(let error):
                presenter?.presentError(error)
            }
        }
    }
    
    func addLocation(name: String, center: CLLocationCoordinate2D) {
        let newLoc = Location(name: name, latitude: center.latitude, longitude: center.longitude)
        locations.append(newLoc)
        presenter?.presentLocations(locations)
        presenter?.presentSelectedLocation(newLoc)
        // We could persist the state but not done as part of this assigment
    }
    
    func deleteLocations(at offsets: IndexSet) {
        locations.remove(atOffsets: offsets)
        presenter?.presentLocations(locations)
        presenter?.presentSelectedLocation(nil)
        // not persisted
    }
}
