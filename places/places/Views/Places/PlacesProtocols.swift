import Foundation
import MapKit
// Ensure Location and protocol types are accessible. If needed, import your app module here.

protocol PlacesBusinessLogic {
    func openWikipedia(for location: Location)
    func fetchLocations()
    func addLocation(name: String, center: CLLocationCoordinate2D)
    func deleteLocations(at offsets: IndexSet)
    func selectLocation(_ location: Location)
}

protocol PlacesPresentationLogic {
    func presentOpenWikipedia(for location: Location)
    func presentLocations(_ locations: [Location])
    func presentError(_ error: Error)
    func presentSelectedLocation(_ location: Location?)
}

protocol PlacesDisplayLogic: AnyObject {
    func displayLocations(_ viewModel: PlacesViewModel.Locations)
    func displayError(_ viewModel: PlacesViewModel.Error)
    func displayOpenWikipedia(for location: Location)
    func displaySelectedLocation(_ location: Location?)
}
