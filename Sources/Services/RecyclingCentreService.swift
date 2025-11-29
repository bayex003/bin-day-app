import CoreLocation
import Foundation

/// Static data for Greater Manchester recycling centres so we can calculate the nearest site.
final class RecyclingCentreService {
    private let centres: [RecyclingCentre] = [
        RecyclingCentre(
            id: "lumns-lane",
            name: "Lumns Lane Recycling Centre",
            address: "Lumns Lane, Swinton M27 8LN",
            coordinate: CLLocationCoordinate2D(latitude: 53.5182, longitude: -2.3132),
            openingHours: "Open daily 8am–6pm"
        ),
        RecyclingCentre(
            id: "cobden-street",
            name: "Cobden Street Recycling Centre",
            address: "Cobden Street, Salford M6 6NA",
            coordinate: CLLocationCoordinate2D(latitude: 53.4881, longitude: -2.2809),
            openingHours: "Open daily 8am–6pm"
        ),
        RecyclingCentre(
            id: "boysnope",
            name: "Boysnope Wharf Recycling Centre",
            address: "Liverpool Road, Irlam M44 5BP",
            coordinate: CLLocationCoordinate2D(latitude: 53.4427, longitude: -2.4035),
            openingHours: "Open daily 8am–6pm"
        )
    ]

    func nearestCentre(to coordinate: CLLocationCoordinate2D) -> RecyclingCentre? {
        guard !centres.isEmpty else { return nil }

        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

        return centres.min { lhs, rhs in
            let lhsDistance = CLLocation(
                latitude: lhs.coordinate.latitude,
                longitude: lhs.coordinate.longitude
            ).distance(from: location)

            let rhsDistance = CLLocation(
                latitude: rhs.coordinate.latitude,
                longitude: rhs.coordinate.longitude
            ).distance(from: location)

            return lhsDistance < rhsDistance
        }
    }
}
