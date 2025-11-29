import Foundation

struct BinPickup: Identifiable, Hashable {
    let id: UUID
    let type: BinType
    let pickupDate: Date
    let notes: String?

    init(id: UUID = UUID(), type: BinType, pickupDate: Date, notes: String? = nil) {
        self.id = id
        self.type = type
        self.pickupDate = pickupDate
        self.notes = notes
    }
}

extension BinType {
    // Provide equivalents that BinCard/NotificationScheduler expect
    var label: String {
        switch self {
        case .general:
            return "General waste"
        case .recyclingBrown:
            return "Recycling (brown bin)"
        case .recyclingBlue:
            return "Recycling (blue bin)"
        case .food:
            return "Food waste"
        case .garden:
            return "Garden waste"
        }
    }

    var systemImageName: String {
        switch self {
        case .general:
            return "trash.fill"
        case .recyclingBrown:
            return "arrow.2.circlepath"
        case .recyclingBlue:
            return "arrow.2.circlepath"
        case .food:
            return "leaf.fill"
        case .garden:
            return "leaf.fill"
        }
    }
}
