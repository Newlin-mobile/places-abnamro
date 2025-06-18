import SwiftUI
import MapKit
import Foundation

struct PlacesView: View {
    @ObservedObject var viewModel: ObservablePlacesViewModel
    var interactor: PlacesBusinessLogic

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
                                viewModel.currentMapCenter = context.camera.centerCoordinate
                            }
                    .frame(height: 250)
                    .onAppear {
                        viewModel.fitAllLocations()
                    }
                    .onChange(of: viewModel.locations) {
                        viewModel.fitAllLocations()
                    }
                    if viewModel.isAddingLocation {
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
                    if !viewModel.isAddingLocation {
                        Button(action: {
                            viewModel.isAddingLocation = true
                        }) {
                            Image(systemName: "plus")
                        }
                    } else {
                        HStack {
                            Button("Done") {
                                viewModel.showAddLocationSheet = true
                            }
                            Button("Cancel") {
                                viewModel.isAddingLocation = false
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $viewModel.showAddLocationSheet) {
                AddLocationSheet(
                    newLocationName: $viewModel.newLocationName,
                                    onAdd: {
                                        interactor.addLocation(name: viewModel.newLocationName, center: viewModel.currentMapCenter)
                                        viewModel.showAddLocationSheet = false
                                        viewModel.isAddingLocation = false

                                    },
                                    onCancel: {
                                        viewModel.showAddLocationSheet = false
                                    }
                                )
                .padding()
                .onAppear { viewModel.newLocationName = "" }
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


