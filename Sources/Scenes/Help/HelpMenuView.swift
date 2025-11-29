import SwiftUI

struct HelpMenuView: View {
    var body: some View {
        List {
            // MARK: - Bin basics
            Section("Bin basics") {
                // This is the row that matches your screenshot
                NavigationLink {
                    BinColourGuideView()
                } label: {
                    Label("What goes in each bin?", systemImage: "questionmark.circle")
                }

                // Recycling help screen (existing view)
                NavigationLink {
                    RecyclingHelpView()
                } label: {
                    Label("Recycling help & tips", systemImage: "leaf.circle")
                }
            }

            // MARK: - Extra info
            Section("Extra info") {
                NavigationLink {
                    CollectionRulesView()
                } label: {
                    Label("Bin collection rules", systemImage: "calendar.badge.clock")
                }

                NavigationLink {
                    AppFAQView()
                } label: {
                    Label("FAQ about this app", systemImage: "info.circle")
                }
            }

            // MARK: - Support
            Section("Support") {
                NavigationLink {
                    ContactSupportView()
                } label: {
                    Label("Contact & feedback", systemImage: "envelope")
                }
            }
        }
        .navigationTitle("Help & Info")
        .navigationBarTitleDisplayMode(.inline)
        .listStyle(.insetGrouped)
    }
}

// MARK: - Bin colour guide (placeholder using your BinType/BinIcon)
struct BinColourGuideView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("What goes in each bin?")
                    .font(.title2.bold())

                binRow(for: .general)
                binRow(for: .recyclingBrown)
                binRow(for: .recyclingBlue)
                binRow(for: .food)
                binRow(for: .garden)

                Text("Tip: Use “Recycling help & tips” for searchable guidance on specific items.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Bin colour guide")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func binRow(for type: BinType) -> some View {
        HStack(spacing: 12) {
            BinIcon(type: type)
            VStack(alignment: .leading, spacing: 4) {
                Text(type.displayName).font(.headline)
                Text(type.detailText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

// MARK: - Collection rules
struct CollectionRulesView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Bin collection rules")
                    .font(.title2.bold())

                Text("""
Here you can explain things like:

• What time bins need to be out
• Where to place them
• How bank holidays affect collections
• What to do if your bin was missed
""")
                    .font(.body)
                    .foregroundColor(.secondary)

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Collection rules")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - FAQ
struct AppFAQView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("FAQ")
                    .font(.title2.bold())

                FAQItem(
                    question: "Why can’t I see my next collection?",
                    answer: "Check that your address is correct and you have an internet connection. If the council API is down, we’ll show a message on the home screen."
                )

                FAQItem(
                    question: "My bin wasn’t collected. What should I do?",
                    answer: "Use the council’s website or phone number to report a missed bin collection. We’ll add a quick link here in a future update."
                )

                Spacer()
            }
            .padding()
        }
        .navigationTitle("FAQ")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FAQItem: View {
    let question: String
    let answer: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(question)
                .font(.headline)

            Text(answer)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Contact Support
struct ContactSupportView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Contact & feedback")
                    .font(.title2.bold())

                Text("""
This is where you can:

• Add a mail link to send feedback
• Link to Salford council’s bin pages
• Add social or website links in future

For now, this is a simple placeholder screen.
""")
                    .font(.body)
                    .foregroundColor(.secondary)

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Contact & feedback")
        .navigationBarTitleDisplayMode(.inline)
    }
}
