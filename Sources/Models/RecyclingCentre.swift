import Foundation
import CoreLocation

struct RecyclingCentre: Identifiable, Equatable {
    let id: String
    let name: String
    let address: String
    let coordinate: CLLocationCoordinate2D
    let openingHours: String

    init(
        id: String = UUID().uuidString,
        name: String,
        address: String,
        coordinate: CLLocationCoordinate2D,
        openingHours: String
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.coordinate = coordinate
        self.openingHours = openingHours
    }
}
