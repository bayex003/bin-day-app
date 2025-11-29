import SwiftUI

struct AboutView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Salford Bin Collection")
                            .font(.title.bold())

                        Text("A simple way to see your next Salford bin collection and set reminders so you don’t miss bin day.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    // How it works
                    VStack(alignment: .leading, spacing: 8) {
                        Text("How it works")
                            .font(.headline)

                        Text("""
This app links your Salford address to Salford City Council’s published collection dates. Once you’ve picked your address, we show your next collection and upcoming dates. You can turn on reminders from the Settings tab.
""")
                        .font(.subheadline)
                    }

                    // Bin tips (short version)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("What goes in each bin (quick guide)")
                            .font(.headline)

                        BinTipsRow(
                            title: "Black bin",
                            detail: "General/domestic waste.",
                            color: Color(red: 0.13, green: 0.13, blue: 0.15)
                        )

                        BinTipsRow(
                            title: "Brown recycling",
                            detail: "Bottles, cans & plastic.",
                            color: Color(red: 0.50, green: 0.30, blue: 0.10)
                        )

                        BinTipsRow(
                            title: "Blue recycling",
                            detail: "Paper & card.",
                            color: Color(red: 0.00, green: 0.45, blue: 0.90)
                        )

                        BinTipsRow(
                            title: "Food waste",
                            detail: "Food scraps in the food caddy or pink-lidded bin.",
                            color: Color(red: 0.10, green: 0.65, blue: 0.25)
                        )

                        BinTipsRow(
                            title: "Garden waste",
                            detail: "Garden clippings and similar waste.",
                            color: Color(red: 0.95, green: 0.10, blue: 0.55)
                        )

                        Text("Always check Salford City Council’s website if you’re unsure about a specific item.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    // Data & Privacy
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Data & privacy")
                            .font(.headline)

                        Text("""
We store only what’s needed on your device:
• Your chosen address
• Your bin schedule
• Your reminder preferences

No analytics or advertising trackers are built into this app.
""")
                        .font(.subheadline)
                    }

                    // Disclaimer
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Disclaimer")
                            .font(.headline)

                        Text("""
This app is not an official app from Salford City Council. Bin dates are based on information published by the council and may occasionally change (for example around bank holidays).

Always refer to the council’s website if anything looks different to what you see here.
""")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    }
                }
                .padding()
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// Small coloured-dot row for each bin type
private struct BinTipsRow: View {
    let title: String
    let detail: String
    let color: Color

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(color)
                .frame(width: 14, height: 14)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.bold())
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
