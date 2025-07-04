//
//  placesTests.swift
//  placesTests
//
//  Created by Ronald Kuiper on 13/06/2025.
//

import Testing
@testable import places

import MapKit

// MARK: - Mock Classes

class MockLocationService: LocationServiceProtocol {
    var fetchLocationsCalled = false
    var result: Result<[Location], ErrorWrapper>?

    func fetchLocations() async -> Result<[Location], ErrorWrapper> {
        fetchLocationsCalled = true
        if let result = result {
            return result
        }
        return .failure(ErrorWrapper(message: "Unable to fetch locations", underlyingError: NSError(domain: "", code: 0, userInfo: nil)))
    }
}

class MockPresenter: PlacesPresentationLogic {
    var presentedLocations: [Location]?
    var presentedError: ErrorWrapper?
    var presentedSelectedLocation: Location?
    var presentedWikipediaLocation: Location?
    
    func presentLocations(_ locations: [Location]) {
        presentedLocations = locations
    }
    func presentError(_ error: ErrorWrapper) {
        presentedError = error
    }
    func presentSelectedLocation(_ location: Location?) {
        presentedSelectedLocation = location
    }
    func presentOpenWikipedia(for location: Location) {
        presentedWikipediaLocation = location
    }
}

class MockView: PlacesDisplayLogic {
    var displayedLocations: [Location]?
    var displayedError: ErrorWrapper?
    var displayedSelectedLocation: Location?
    var displayedWikipediaLocation: Location?
    
    func displayLocations(_ locations: [Location]) {
        displayedLocations = locations
    }
    func displayError(_ errorMessage: ErrorWrapper) {
        displayedError = errorMessage
    }
    func displayOpenWikipedia(for location: Location) {
        displayedWikipediaLocation = location
    }
    func displaySelectedLocation(_ location: Location?) {
        displayedSelectedLocation = location
    }
}

// MARK: - Unit Tests

struct placesTests {
    @Test func testFetchLocationsSuccess() async throws {
        let mockService = MockLocationService()
        let mockPresenter = MockPresenter()
        let interactor = PlacesInteractor(service: mockService)
        interactor.presenter = mockPresenter
        let sampleLocations = [Location(name: "Test", latitude: 1.0, longitude: 2.0)]
        mockService.result = .success(sampleLocations)
        interactor.fetchLocations()
        // Simulate async
        try await Task.sleep(for: .seconds(1))
        #expect(mockPresenter.presentedLocations == sampleLocations)
    }
    
    @Test func testFetchLocationsFailure() async throws {
        struct TestError: Error, Equatable { let msg: String }
        let mockService = MockLocationService()
        let mockPresenter = MockPresenter()
        let interactor = PlacesInteractor(service: mockService)
        interactor.presenter = mockPresenter
        let error = ErrorWrapper(message: "Failed to load locations", underlyingError: TestError(msg: "fail"))
        mockService.result = .failure(error)
        interactor.fetchLocations()
        try await Task.sleep(for: .seconds(1))
        #expect(mockPresenter.presentedError == error)
    }

    @Test func testAddLocation() async throws {
        let mockService = MockLocationService()
        let mockPresenter = MockPresenter()
        let interactor = PlacesInteractor(service: mockService)
        interactor.presenter = mockPresenter
        let coord = CLLocationCoordinate2D(latitude: 1.0, longitude: 2.0)
        interactor.addLocation(name: "New Place", center: coord)
        #expect(mockPresenter.presentedLocations?.contains(where: { $0.name == "New Place" }) == true)
    }

    @Test func testPresenterCallsView() async throws {
        let presenter = PlacesPresenter()
        let mockView = MockView()
        presenter.view = mockView
        let locations = [Location(name: "Test", latitude: 1, longitude: 2)]
        presenter.presentLocations(locations)
        #expect(mockView.displayedLocations == locations)
        let error = ErrorWrapper(message: "Failed to load locations", underlyingError: NSError(domain: "", code: 1, userInfo: [NSLocalizedDescriptionKey: "error"]))
        presenter.presentError(error)
        #expect(mockView.displayedError?.message == "Failed to load locations")
        presenter.presentSelectedLocation(locations[0])
        #expect(mockView.displayedSelectedLocation == locations[0])
        presenter.presentOpenWikipedia(for: locations[0])
        #expect(mockView.displayedWikipediaLocation == locations[0])
    }

    @Test func testLocationsJSONParsing() async throws {
        // Load locations.json from the same directory as this test file
        let testFilePath = URL(fileURLWithPath: #file)
        let testDir = testFilePath.deletingLastPathComponent()
        let jsonURL = testDir.appendingPathComponent("locations.json")
        let data = try Data(contentsOf: jsonURL)
        let decoder = JSONDecoder()
        let wrapper = try decoder.decode(LocationsWrapper.self, from: data)
        // There should be 4 locations, as in the file
        #expect(wrapper.locations.count == 4)
        // Check first location fields
        #expect(wrapper.locations[0].name == "Amsterdam")
        #expect(wrapper.locations[0].latitude == 52.3547498)
        #expect(wrapper.locations[0].longitude == 4.8339215)
        // Check last location has nil name
        #expect(wrapper.locations[3].name == nil)
    }
}

