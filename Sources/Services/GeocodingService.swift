import CoreLocation
import Foundation

enum GeocodingError: Error, LocalizedError {
    case noResult

    var errorDescription: String? {
        switch self {
        case .noResult:
            return "Could not find a location for that postcode."
        }
    }
}

/// Lightweight geocoder so we can map postcodes to coordinates for the map view.
final class GeocodingService {
    private let geocoder = CLGeocoder()

    func coordinate(for postcode: String) async throws -> CLLocationCoordinate2D {
        let query = postcode.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !query.isEmpty else {
            throw GeocodingError.noResult
        }

        let placemarks = try await geocoder.geocodeAddressString(query)

        guard let location = placemarks.first?.location else {
            throw GeocodingError.noResult
        }

        return location.coordinate
    }
}
