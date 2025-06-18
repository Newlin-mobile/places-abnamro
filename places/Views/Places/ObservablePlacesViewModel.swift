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
    @Published var errorMessage: String? = nil
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

    func displayError(_ message: String) {
        errorMessage = message
    }

    func displaySelectedLocation(_ location: Location?) {
        self.selectedLocation = location
    }

    /// Adjusts mapRegion to fit all locations
    func fitAllLocations() {

        let coords = locations.compactMap { loc -> CLLocationCoordinate2D? in
            return CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude)
        }
        guard !coords.isEmpty else { return }
        if coords.count == 1 {
            mapRegion = MKCoordinateRegion(center: coords[0], span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
            return
        }
        let minLat = coords.map { $0.latitude }.min() ?? 0
        let maxLat = coords.map { $0.latitude }.max() ?? 0

        let minLon = coords.map { $0.longitude }.min() ?? 0
        let maxLon = coords.map { $0.longitude }.max() ?? 0
        let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2, longitude: (minLon + maxLon) / 2)
        let span = MKCoordinateSpan(latitudeDelta: max(0.1, (maxLat - minLat) * 1.3), longitudeDelta: max(0.1, (maxLon - minLon) * 1.3))

        mapCameraPosition = .region(
            MKCoordinateRegion(center: center, span: span)
        )
    }
}
