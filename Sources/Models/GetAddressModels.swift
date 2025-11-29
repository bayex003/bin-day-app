import Foundation

struct GetAddressFindResponse: Codable {
    let postcode: String
    let latitude: Double?
    let longitude: Double?
    let addresses: [String]
}
