# Places App Assignment

I made this example app as part of the ABN AMRO assignment, see also the iOS assignment 2024.pdf for the requirements. As part of the assignment I created a fork of the wikipedia app see https://github.com/Newlin-mobile/wikipedia-ios and use branch "feature/open-places-from-link"


A simple SwiftUI app that displays a list of locations fetched from a remote JSON endpoint. Tapping a location opens the Wikipedia app for that place. Users can also enter a custom location to search in Wikipedia.

## Features
- Fetches locations from: https://raw.githubusercontent.com/abnamrocoesd/assignment-ios/main/locations.json
- Displays locations in a SwiftUI List
- Tapping a location opens the Wikipedia app (or Safari if not installed)
- Enter a custom location to open in Wikipedia
- Uses Swift Concurrency (async/await)
- Accessibility labels and hints
- Unit tested networking and view models

## Getting Started
1. Open the project in Xcode 15+
2. Run on iOS 17+ simulator or device

## Running Tests
- Select the test target and press Cmd+U

## Assignment Requirements
- SwiftUI
- ReadMe
- Unit tests
- Bonus: Swift Concurrency, Accessibility

---

Made for ABN AMRO assignment.
