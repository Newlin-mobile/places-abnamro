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
    var result: Result<[Location], Error>?
    func fetchLocations(completion: @escaping (Result<[Location], Error>) -> Void) {
        fetchLocationsCalled = true
        if let result = result {
            completion(result)
        }
    }
}

class MockPresenter: PlacesPresentationLogic {
    var presentedLocations: [Location]?
    var presentedError: Error?
    var presentedSelectedLocation: Location?
    var presentedWikipediaLocation: Location?
    
    func presentLocations(_ locations: [Location]) {
        presentedLocations = locations
    }
    func presentError(_ error: Error) {
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
    var displayedLocations: PlacesViewModel.Locations?
    var displayedError: PlacesViewModel.Error?
    var displayedSelectedLocation: Location?
    var displayedWikipediaLocation: Location?
    
    func displayLocations(_ viewModel: PlacesViewModel.Locations) {
        displayedLocations = viewModel
    }
    func displayError(_ viewModel: PlacesViewModel.Error) {
        displayedError = viewModel
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
        try await Task.sleep(nanoseconds: 100_000_000)
        #expect(mockPresenter.presentedLocations == sampleLocations)
    }
    
    @Test func testFetchLocationsFailure() async throws {
        struct TestError: Error, Equatable { let msg: String }
        let mockService = MockLocationService()
        let mockPresenter = MockPresenter()
        let interactor = PlacesInteractor(service: mockService)
        interactor.presenter = mockPresenter
        let error = TestError(msg: "fail")
        mockService.result = .failure(error)
        interactor.fetchLocations()
        try await Task.sleep(nanoseconds: 100_000_000)
        #expect((mockPresenter.presentedError as? TestError)?.msg == "fail")
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
        #expect(mockView.displayedLocations?.locations == locations)
        let error = NSError(domain: "", code: 1, userInfo: [NSLocalizedDescriptionKey: "error"])
        presenter.presentError(error)
        #expect(mockView.displayedError?.message == "error")
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

