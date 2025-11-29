import SwiftUI

/// Card that shows the next bin collection, using your existing BinCollection model.
struct NextCollectionCard: View {
    let isLoading: Bool
    let error: String?
    let collections: [BinCollection]

    private let calendar = Calendar.current

    /// All collections for the earliest upcoming date,
    /// sorted by bin type name so they appear in a stable order.
    private var nextDayCollections: [BinCollection] {
        guard let first = collections.sorted(by: { $0.date < $1.date }).first else {
            return []
        }
        let cal = Calendar.current
        return collections
            .filter { cal.isDate($0.date, inSameDayAs: first.date) }
            .sorted { $0.type.displayName < $1.type.displayName }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            Text("Next collection")
                .font(.headline)
                .foregroundColor(.secondary)

            // State handling
            if isLoading {
                LoadingStateView()
            } else if let error = error {
                ErrorStateView(message: error)
            } else if let first = nextDayCollections.first {
                // Success state: show the date + bin rows
                Text(formattedDate(first.date))
                    .font(.title3.bold())

                VStack(spacing: 8) {
                    ForEach(nextDayCollections.indices, id: \.self) { index in
                        BinRowView(collection: nextDayCollections[index])
                    }
                }
            } else {
                // No data, no error
                Text("No upcoming collections found.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        )
    }

    // MARK: - Helpers

    private func formattedDate(_ date: Date) -> String {
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInTomorrow(date) {
            return "Tomorrow"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE d MMM"
            return formatter.string(from: date)
        }
    }
}

// MARK: - Loading + Error views

private struct LoadingStateView: View {
    var body: some View {
        HStack(spacing: 12) {
            ProgressView()
            Text("Loading next collection…")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

private struct ErrorStateView: View {
    let message: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.red)
        }
    }
}

// MARK: - Bin row view

private struct BinRowView: View {
    let collection: BinCollection

    private var lowerName: String {
        collection.type.displayName.lowercased()
    }

    private var binLabel: String {
        if lowerName.contains("food") {
            return "Food waste"
        } else if lowerName.contains("garden") {
            return "Garden waste"
        } else if lowerName.contains("blue") || lowerName.contains("paper") || lowerName.contains("card") {
            return "Blue bin"
        } else if lowerName.contains("brown") || lowerName.contains("bottle") || lowerName.contains("can") || lowerName.contains("plastic") {
            return "Brown bin"
        } else if lowerName.contains("grey") || lowerName.contains("gray") || lowerName.contains("general") {
            return "Grey bin"
        } else {
            return collection.type.displayName
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            binIcon
                .frame(width: 36, height: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(binLabel)
                    .font(.subheadline.bold())

                // Show the raw type text underneath (nice for future extra info)
                Text(collection.type.displayName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }

    // MARK: - Icon styling

    @ViewBuilder
    private var binIcon: some View {
        if lowerName.contains("food") {
            // Food waste – solid green
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.green)
        } else if lowerName.contains("garden") {
            // Garden waste – half black, half pink
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

            RoundedRectangle(cornerRadius: 8)
                .fill(gradient)
        } else if lowerName.contains("blue") || lowerName.contains("paper") || lowerName.contains("card") {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.blue)
        } else if lowerName.contains("brown") || lowerName.contains("bottle") || lowerName.contains("can") || lowerName.contains("plastic") {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.brown)
        } else if lowerName.contains("grey") || lowerName.contains("gray") || lowerName.contains("general") {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray)
        } else {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.7))
        }
    }
}
