import Foundation
import MapKit
// Ensure Location and protocol types are accessible. If needed, import your app module here.

class PlacesPresenter: PlacesPresentationLogic {
    func presentSelectedLocation(_ location: Location?) {
        view?.displaySelectedLocation(location)
    }
    
    func presentOpenWikipedia(for location: Location) {
        view?.displayOpenWikipedia(for: location)
    }
    
    weak var view: PlacesDisplayLogic?
    
    func presentLocations(_ locations: [Location]) {
        view?.displayLocations(locations)
    }
    
    func presentError(_ error: ErrorWrapper) {
        view?.displayError(error)
    }
}
