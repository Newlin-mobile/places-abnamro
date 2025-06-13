import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject private var service = LocationService()
    @State private var mapRegion: MKCoordinateRegion = MKCoordinateRegion()
    @State private var regionIsSet = false

    var body: some View {
        NavigationView {
            VStack {
                Map(coordinateRegion: $mapRegion, annotationItems: service.locations.compactMap { loc in
                    (loc.latitude != nil && loc.longitude != nil) ? loc : nil
                }) { location in
                    MapMarker(coordinate: CLLocationCoordinate2D(latitude: location.latitude!, longitude: location.longitude!), tint: .blue)
                }
                .frame(height: 250)
                .onAppear {
                    fitAllLocations()
                }
                .onChange(of: service.locations) { _ in
                    fitAllLocations()
                }

                List(service.locations) { location in
                    Button(action: {
                        openWikipedia(for: location)
                    }) {
                        VStack(alignment: .leading) {

                            Text(location.name ?? "Unknown Location")
                                .font(.headline)

                        }
                        .accessibilityElement(children: .combine)
                        //.accessibilityLabel("\(location.name), \(location.country ?? "")")
                    }
                }
                .listStyle(.plain)
                .accessibilityIdentifier("locationList")

                /*HStack {
                    TextField("Enter custom location", text: $customLocation)
                        .textFieldStyle(.roundedBorder)
                        .accessibilityLabel("Custom location input")
                        .focused($isTextFieldFocused)
                    Button("Open") {
                        //openWikipedia(for: Location(name: <#T##String?#>, latitude: <#T##Double?#>, longitude: <#T##Double?#>))
                        isTextFieldFocused = false
                    }
                    .disabled(customLocation.isEmpty)
                    .accessibilityLabel("Open Wikipedia for custom location")
                }
                .padding()*/
            }
            .navigationTitle("Places")
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
            var minLat = coords.map { $0.latitude }.min() ?? 0
            var maxLat = coords.map { $0.latitude }.max() ?? 0
            var minLon = coords.map { $0.longitude }.min() ?? 0
            var maxLon = coords.map { $0.longitude }.max() ?? 0
            let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2, longitude: (minLon + maxLon) / 2)
            let span = MKCoordinateSpan(latitudeDelta: max(0.1, (maxLat - minLat) * 1.3), longitudeDelta: max(0.1, (maxLon - minLon) * 1.3))
            mapRegion = MKCoordinateRegion(center: center, span: span)
        }
}

#Preview {
    ContentView()
}
