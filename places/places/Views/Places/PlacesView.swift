import SwiftUI
import MapKit
// Import Location model if needed
import Foundation

struct PlacesView: View {
    @ObservedObject var viewModel: ObservablePlacesViewModel
    var interactor: PlacesBusinessLogic

    @State private var showAddLocationSheet = false
    @State private var newLocationName = ""
    @State private var isAddingLocation = false
    @State private var currentMapCenter: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)

    private func openWikipedia(for query: Location) {
        let wikiURL = URL(string: "wikipedia://places?WMFLatitude=\(query.latitude)&WMFLongitude=\(query.longitude)")!
                UIApplication.shared.open(wikiURL)
        }

    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    Map(position: $viewModel.mapCameraPosition) {
                                mapAnnotations
                            }.onMapCameraChange { context in
                                currentMapCenter = context.camera.centerCoordinate
                            }
                    .frame(height: 250)
                    .onAppear {
                        viewModel.fitAllLocations()
                    }
                    .onChange(of: viewModel.locations) {
                        viewModel.fitAllLocations()
                    }
                    if isAddingLocation {
                        markerCenterContent()
                    }
                }
                List {
                    ForEach(viewModel.locations) { location in
                        HStack {
                            Button(action: {
                                interactor.selectLocation(location)
                            }) {
                                HStack {
                                    Text(location.name ?? "Unknown")
                                    Spacer()
                                }
                            }
                            .contentShape(Rectangle())
                            if viewModel.selectedLocation == location {
                                Button(action: {
                                    interactor.openWikipedia(for: location)
                                }) {
                                    HStack(spacing: 4) {
                                        Text("Open in Wikipedia")
                                            .foregroundColor(Color(.abnTeal))
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                    }
                    .onDelete(perform: interactor.deleteLocations)
                }
                .listStyle(.plain)
            }
            .navigationTitle("Places")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !isAddingLocation {
                        Button(action: {
                            isAddingLocation = true
                        }) {
                            Image(systemName: "plus")
                        }
                    } else {
                        HStack {
                            Button("Done") {
                                showAddLocationSheet = true
                            }
                            Button("Cancel") {
                                isAddingLocation = false
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showAddLocationSheet) {
                AddLocationSheet(
                                    newLocationName: $newLocationName,
                                    onAdd: {
                                        interactor.addLocation(name: newLocationName, center: currentMapCenter)
                                        showAddLocationSheet = false
                                        isAddingLocation = false

                                    },
                                    onCancel: {
                                        showAddLocationSheet = false
                                    }
                                )
                .padding()
                .onAppear { newLocationName = "" }
            }
        }
        .onAppear {
            interactor.fetchLocations()
        }
        // Observe openWikipediaLocation and trigger helper if set
        .onChange(of: viewModel.openWikipediaLocation) { oldLocation, newLocation in
            if let location = newLocation {
                openWikipedia(for: location)
                viewModel.openWikipediaLocation = nil // Reset after handling
            }
        }
    }

    @MapContentBuilder
        var mapAnnotations: some MapContent {
            ForEach(viewModel.locations) { location in
                Annotation(
                    "", coordinate: CLLocationCoordinate2D(
                        latitude: location.latitude,
                        longitude: location.longitude
                    ),
                    anchor: .bottom
                ) {
                    annotationButton(for: location)
                }
            }
        }

    func annotationButton(for location: Location) -> some View {
        Button(action: {
            interactor.selectLocation(location)
        }) {
            markerView(for: location)
        }
    }

    
    @ViewBuilder
    private func markerView(for location: Location) -> some View {
        VStack(spacing: 5) {
            Text(location.name ?? "Unknown Location")
                .font(.caption)
                .padding(5)
                .background(Color(.systemBackground))
                .foregroundColor(Color(.abnTeal))
                .cornerRadius(8)
                .shadow(radius: 3)
            Image(systemName: viewModel.selectedLocation == location ? "mappin.circle.fill" : "mappin")
                .font(.title)
                .foregroundColor(viewModel.selectedLocation == location ? Color(.abnTeal) : Color(.abnDarkGray))
        }
    }
    
    @ViewBuilder
    private func markerCenterContent() -> some View {
        VStack(spacing: 5) {
            Text("Move map for new location")
                .font(.caption)
                .padding(5)
                .background(Color(.systemBackground))
                .cornerRadius(8)
                .shadow(radius: 3)
            Image(systemName: "plus.circle.fill")
                .foregroundColor(Color(.abnYellow))
                .font(.title)
        }
    }
}

class ObservablePlacesViewModel: ObservableObject, PlacesDisplayLogic {
    @Published var locations: [Location] = []
    @Published var errorMessage: String? = nil
    @Published var mapRegion: MKCoordinateRegion = MKCoordinateRegion()

    @Published var mapCameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 52.3702, longitude: 4.8952), // example: Amsterdam
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
    )
    @Published var selectedLocation: Location? = nil
    @Published var openWikipediaLocation: Location? = nil

    func displayOpenWikipedia(for location: Location) {
        openWikipediaLocation = location
    }

    func displayLocations(_ viewModel: PlacesViewModel.Locations) {
        locations = viewModel.locations
    }

    func displayError(_ viewModel: PlacesViewModel.Error) {
        errorMessage = viewModel.message
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
