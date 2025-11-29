import CoreLocation
import Foundation

enum GeocodingServiceError: Error, LocalizedError {
    case noResults
    case underlying(Error)

    var errorDescription: String? {
        switch self {
        case .noResults:
            return "Couldn't find that location. Check the postcode and try again."
        case .underlying:
            return "We couldn't look up that postcode just now."
        }
    }
}

final class GeocodingService {
    private let geocoder = CLGeocoder()

    func coordinates(for postcode: String) async throws -> CLLocationCoordinate2D {
        let query = postcode.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !query.isEmpty else {
            throw GeocodingServiceError.noResults
        }

        do {
            let placemarks = try await geocoder.geocodeAddressString(query)
            if let coordinate = placemarks.first?.location?.coordinate {
                return coordinate
            }
            throw GeocodingServiceError.noResults
        } catch let error as CLError {
            if error.code == .geocodeFoundNoResult {
                throw GeocodingServiceError.noResults
            }
            throw GeocodingServiceError.underlying(error)
        } catch {
            throw GeocodingServiceError.underlying(error)
        }
    }
}
