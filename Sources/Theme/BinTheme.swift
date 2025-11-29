import SwiftUI

enum BinTheme {
    static let primary = Color.accentColor

    static func accent(for type: BinType) -> Color {
        switch type {
        case .general:
            return Color(red: 0.18, green: 0.20, blue: 0.22) // dark grey / black bin
        case .recyclingBrown:
            return Color(red: 0.50, green: 0.30, blue: 0.10) // brown
        case .recyclingBlue:
            return Color(red: 0.00, green: 0.45, blue: 0.90) // blue
        case .food:
            return Color(red: 0.10, green: 0.65, blue: 0.25) // green-ish for food
        case .garden:
            return Color(red: 0.90, green: 0.10, blue: 0.50) // pink-ish for garden
        }
    }
}
