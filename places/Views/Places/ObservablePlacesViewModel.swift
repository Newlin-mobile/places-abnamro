//
//  ObservablePlacesViewModel.swift
//  places
//
//  Created by Ronald Kuiper on 18/06/2025.
//


import SwiftUI
import MapKit
import Foundation

class ObservablePlacesViewModel: ObservableObject, PlacesDisplayLogic {
    @Published var locations: [Location] = []
    @Published var errorMessage: ErrorWrapper? = nil
    @Published var mapRegion: MKCoordinateRegion = MKCoordinateRegion()

    @Published var mapCameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 52.3702, longitude: 4.8952), // if still loading show Amsterdam
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
    )
    @Published var selectedLocation: Location? = nil
    @Published var openWikipediaLocation: Location? = nil

    @Published var showAddLocationSheet = false
    @Published var newLocationName = ""
    @Published var isAddingLocation = false
    @Published var currentMapCenter: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)

    func displayOpenWikipedia(for location: Location) {
        openWikipediaLocation = location
    }

    func displayLocations(_ locations: [Location]) {
        self.locations = locations
    }

    func displayError(_ message: ErrorWrapper) {
        errorMessage = message
    }

    func displaySelectedLocation(_ location: Location?) {
        self.selectedLocation = location
    }

    /// Adjusts mapRegion to fit all locations
    func fitAllLocations() {
        let coords = locations.compactMap {
            CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)
        }

        guard !coords.isEmpty else { return }

        if coords.count == 1 {
            mapCameraPosition = .region(
                MKCoordinateRegion(center: coords[0],
                                   span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
            )
            return
        }
        
        var zoomRect = MKMapRect.null
        for coord in coords {
            let point = MKMapPoint(coord)
            let rect = MKMapRect(x: point.x, y: point.y, width: 0.1, height: 0.1)
            zoomRect = zoomRect.union(rect)
        }

        let paddedRect = zoomRect.insetBy(dx: -zoomRect.size.width * 0.2,
                                          dy: -zoomRect.size.height * 0.2)
        var region = MKCoordinateRegion(paddedRect)

        // Bias downward to allow room for pin + label (try 25%)
        region.center.latitude += region.span.latitudeDelta * 0.20
        mapCameraPosition = .region(region)

    }


}
