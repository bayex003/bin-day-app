import SwiftUI

struct BinIcon: View {
    let type: BinType

    private var lowerName: String {
        type.displayName.lowercased()
    }

    var body: some View {
        icon
            .frame(width: 28, height: 28)
    }

    @ViewBuilder
    private var icon: some View {
        if lowerName.contains("food") {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.green)
        } else if lowerName.contains("garden") {
            let gradient = LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: .black, location: 0.0),
                    .init(color: .black, location: 0.5),
                    .init(color: .pink,  location: 0.5),
                    .init(color: .pink,  location: 1.0)
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
            RoundedRectangle(cornerRadius: 6)
                .fill(gradient)
        } else if lowerName.contains("blue") || lowerName.contains("paper") || lowerName.contains("card") {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.blue)
        } else if lowerName.contains("brown") || lowerName.contains("bottle") || lowerName.contains("can") || lowerName.contains("plastic") {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.brown)
        } else if lowerName.contains("grey") || lowerName.contains("gray") || lowerName.contains("general") {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.gray)
        } else {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.gray.opacity(0.7))
        }
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 12) {
        HStack { BinIcon(type: .food); Text("Food") }
        HStack { BinIcon(type: .garden); Text("Garden") }
        HStack { BinIcon(type: .recyclingBlue); Text("Blue") }
        HStack { BinIcon(type: .recyclingBrown); Text("Brown") }
        HStack { BinIcon(type: .general); Text("General") }
    }
    .padding()
}
