import Foundation

struct AddressItem: Identifiable, Codable, Equatable {
    let id: UUID
    var label: String
    var postcode: String
    var uprn: String?

    init(
        id: UUID = UUID(),
        label: String,
        postcode: String,
        uprn: String? = nil
    ) {
        self.id = id
        self.label = label
        self.postcode = postcode
        self.uprn = uprn
    }
}
