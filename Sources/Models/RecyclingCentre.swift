import CoreLocation
import Foundation

struct RecyclingCentre: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let address: String
    let coordinate: CLLocationCoordinate2D
}

struct RecyclingCentreLocator {
    private let centres: [RecyclingCentre] = [
        RecyclingCentre(
            name: "Salford Recycling Centre",
            address: "Lumns Lane, Clifton, M27 8LN",
            coordinate: CLLocationCoordinate2D(latitude: 53.5156, longitude: -2.3298)
        ),
        RecyclingCentre(
            name: "Irlam Recycling Centre",
            address: "Liverpool Road, Irlam, M44 6RL",
            coordinate: CLLocationCoordinate2D(latitude: 53.4446, longitude: -2.4302)
        ),
        RecyclingCentre(
            name: "Stretford Recycling Centre",
            address: "Chester Road, Stretford, M32 9BD",
            coordinate: CLLocationCoordinate2D(latitude: 53.4542, longitude: -2.3216)
        )
    ]

    func nearestCentre(to coordinate: CLLocationCoordinate2D) -> (centre: RecyclingCentre, distance: CLLocationDistance)? {
        guard !centres.isEmpty else { return nil }

        let source = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

        return centres.compactMap { centre in
            let destination = CLLocation(latitude: centre.coordinate.latitude, longitude: centre.coordinate.longitude)
            let distance = source.distance(from: destination)
            return (centre, distance)
        }
        .min { $0.distance < $1.distance }
    }
}
