import SwiftUI

struct BinCard: View {
    let pickup: BinPickup

    private var formattedDate: String {
        pickup.pickupDate.formatted(date: .abbreviated, time: .shortened)
    }

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(BinTheme.accent(for: pickup.type))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: pickup.type.systemImageName)
                        .foregroundStyle(.white)
                )

            VStack(alignment: .leading, spacing: 6) {
                Text(pickup.type.label)
                    .font(.headline)
                Text(formattedDate)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                if let notes = pickup.notes {
                    Text(notes)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(pickup.type.label) pickup on \(formattedDate)")
    }
}

struct BinCard_Previews: PreviewProvider {
    static var previews: some View {
        let sample = BinPickup(
            type: .recyclingBlue,
            pickupDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date(),
            notes: "Put out by 7am"
        )

        return List {
            BinCard(pickup: sample)
        }
        .environmentObject(AppState())
    }
}
