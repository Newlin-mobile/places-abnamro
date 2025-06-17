import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject private var service = LocationService()
    @State private var mapRegion: MKCoordinateRegion = MKCoordinateRegion()
    @State private var regionIsSet = false
    @State private var isAddingLocation = false
    @State private var selectedLocation: Location? = nil
    @State private var newLocationName: String = ""
    @State private var showAddLocationSheet = false
    @FocusState private var isNameFieldFocused: Bool

    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    Map(coordinateRegion: $mapRegion, annotationItems: service.locations.compactMap { loc in
                        (loc.latitude != nil && loc.longitude != nil) ? loc : nil
                    }) { location in
                        MapAnnotation(coordinate: CLLocationCoordinate2D(
                            latitude: location.latitude!,
                            longitude: location.longitude!
                        )) {
                            markerView(for: location)
                        }
                    }
                    .frame(height: 250)
                    .onAppear {
                        fitAllLocations()
                    }
                    .onChange(of: service.locations) {
                        fitAllLocations()
                    }
                    // Center marker overlay
                    markerCenterContent()
                }

                List {
                    ForEach(service.locations) { location in
                        Button(action: {
                            selectedLocation = location
                            if let lat = location.latitude, let lon = location.longitude {
                                withAnimation {
                                    mapRegion = MKCoordinateRegion(
                                        center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                                        span: MKCoordinateSpan(latitudeDelta: 5.0, longitudeDelta: 5.0)
                                    )
                                }
                            }
                        }) {
                            HStack() {
                                Text(location.name ?? "Unknown Location")
                                    .font(.headline)
                                Spacer()
                                if (location == selectedLocation) {
                                    Button("Open in Wikipedia", action: {
                                        print("Tapped on \(location.name ?? "Unknown")")
                                        openWikipedia(for: location)
                                    }).foregroundColor(Color(.abnTeal))
                                    Image(systemName: "chevron.right")
                                }
                            }
                        }
                    }
                    .onDelete(perform: deleteLocations)
                }
                .listStyle(.plain)
                .background(Color(.abnLightGray))
                .accessibilityIdentifier("locationList")
            }
            .sheet(isPresented: $showAddLocationSheet) {
                AddLocationSheet(
                    newLocationName: $newLocationName,
                    onAdd: {
                        let center = mapRegion.center
                        let newLoc = Location(name: newLocationName, latitude: center.latitude, longitude: center.longitude)
                        service.locations.append(newLoc)
                        showAddLocationSheet = false
                    },
                    onCancel: {
                        showAddLocationSheet = false
                    }
                )
                .onAppear {
                    newLocationName = ""
                }
            }
            .navigationTitle("Places")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if isAddingLocation {
                        Button(action: {
                            isAddingLocation = false
                        }) {
                            Text("Cancel")
                                .foregroundColor(Color(.abnGreen))

                        }

                        Button(action: {
                            showAddLocationSheet = true
                            isAddingLocation = false
                        }) {
                            Text("Done")
                                .foregroundColor(Color(.abnGreen))
                        }
                    } else {
                        Button(action: {
                            print("Add tapped")
                            isAddingLocation = true
                        }) {
                            Image(systemName: "plus")
                                .foregroundColor(Color(.abnGreen))
                        }
                    }
                }
            }
            .task {
                await service.fetchLocations()
            }
            .alert(item: $service.errorMessage) { err in
                Alert(title: Text("Error"), message: Text(err.message), dismissButton: .default(Text("OK")) {
                    service.errorMessage = nil
                })
            }
        }
    }

    func deleteLocations(at offsets: IndexSet) {
        service.locations.remove(atOffsets: offsets)
    }

    @ViewBuilder
    func markerView(for location: Location) -> some View {
        VStack(spacing: 5) {
            Text(location.name ?? "Unknown Location")
                .font(.caption)
                .padding(5)
                .background(Color(.systemBackground))
                .cornerRadius(8)
                .shadow(radius: 3)

            Image(systemName: location == selectedLocation ? "mappin.circle.fill" : "mappin")
                .font(.title)
                .foregroundColor(Color(.abnTeal))
        }
        .onTapGesture {
            print("Tapped on \(location.name ?? "Unknown")")
            selectedLocation = location
        }
    }

    @ViewBuilder
    func markerCenterContent() -> some View {
        if isAddingLocation || showAddLocationSheet {
            VStack(spacing: 5) {
                Text("Move map for new location")
                    .font(.caption)
                    .padding(5)
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
                    .shadow(radius: 3)

                Image(systemName: "plus.circle.fill")
                    .font(.title)
                    .foregroundColor(Color(.abnTeal))
            }
        }
    }

    private func openWikipedia(for query: Location) {
        let wikiURL = URL(string: "wikipedia://places?WMFLatitude=\(query.latitude ?? 0)&WMFLongitude=\(query.longitude ?? 0)")!
            UIApplication.shared.open(wikiURL)
    }

        private func fitAllLocations() {
            let coords = service.locations.compactMap { loc -> CLLocationCoordinate2D? in
                guard let lat = loc.latitude, let lon = loc.longitude else { return nil }
                return CLLocationCoordinate2D(latitude: lat, longitude: lon)
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
            mapRegion = MKCoordinateRegion(center: center, span: span)
        }
}

#Preview("Light Mode") {
    ContentView()
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    ContentView()
        .preferredColorScheme(.dark)
}
