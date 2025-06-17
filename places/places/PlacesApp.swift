import SwiftUI

@main
struct PlacesApp: App {
    // Set up the VIP stack as a computed property
    var rootView: some View {
        let viewModel = ObservablePlacesViewModel()
        let presenter = PlacesPresenter()
        presenter.view = viewModel
        let interactor = PlacesInteractor(service: LocationService())
        interactor.presenter = presenter
        return PlacesView(viewModel: viewModel, interactor: interactor)
    }

    var body: some Scene {
        WindowGroup {
            rootView
        }
    }
}
