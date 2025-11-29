import Foundation

/// Salford-specific bin types.
enum BinType: String, Codable, CaseIterable, Identifiable {
    case general          // black bin
    case recyclingBrown   // brown recycling (bottles & cans, plastics)
    case recyclingBlue    // blue recycling (paper & card)
    case food             // food waste
    case garden           // garden waste

    var id: String { rawValue }

    // Title shown in the UI
    var displayName: String {
        switch self {
        case .general:
            return "General waste"
        case .recyclingBrown:
            return "Brown recycling"
        case .recyclingBlue:
            return "Blue recycling"
        case .food:
            return "Food waste"
        case .garden:
            return "Garden waste"
        }
    }

    // Subtitle / detail under the title
    var detailText: String {
        switch self {
        case .general:
            return "Domestic waste (black bin)"
        case .recyclingBrown:
            return "Bottles, cans & plastic (brown bin)"
        case .recyclingBlue:
            return "Paper & card (blue bin)"
        case .food:
            return "Food waste (caddy / pink lid bin)"
        case .garden:
            return "Garden waste (pink lid bin)"
        }
    }
}

/// A single scheduled bin collection (date + bin type).
struct BinCollection: Identifiable, Hashable {
    let id: UUID
    let date: Date
    let type: BinType

    init(id: UUID = UUID(), date: Date, type: BinType) {
        self.id = id
        self.date = date
        self.type = type
    }
}
