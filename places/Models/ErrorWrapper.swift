import Foundation

/// A wrapper for errors that can be displayed in the UI.
public struct ErrorWrapper: Identifiable, Error, Equatable {
    public let id = UUID()
    let message: String
    let underlyingError: Error?
    
    init(message: String, underlyingError: Error? = nil) {
        self.message = message
        self.underlyingError = underlyingError
    }
    
    public static func == (lhs: ErrorWrapper, rhs: ErrorWrapper) -> Bool {
        lhs.id == rhs.id
    }
}
