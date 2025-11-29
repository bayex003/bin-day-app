import SwiftUI

struct RecyclingHelpView: View {
    @State private var query: String = ""

    // All items, filtered by search text
    private var filtered: [RecyclingItem] {
        RecyclingData.items.filter { $0.matches(query) }
    }

    // Group filtered items by bin type
    private var grouped: [(bin: BinType, items: [RecyclingItem])] {
        let dict = Dictionary(grouping: filtered) { $0.bin }

        // Custom order of sections
        let order: [BinType] = [.general, .recyclingBrown, .recyclingBlue, .food, .garden]

        return order
            .compactMap { bin in
                if let items = dict[bin] {
                    return (bin: bin, items: items)
                }
                return nil
            }
    }

    var body: some View {
        NavigationStack {
            List {
                // Search bar
                Section {
                    TextField("Search e.g. 'pizza box', 'bottle', 'nappy'", text: $query)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }

                // Results grouped by bin
                ForEach(grouped, id: \.bin.id) { group in
                    Section(header: binHeader(for: group.bin)) {
                        ForEach(group.items) { item in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.name)
                                    .font(.subheadline.bold())

                                Text(item.examples)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Recycling help")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    @ViewBuilder
    private func binHeader(for bin: BinType) -> some View {
        HStack(spacing: 8) {
            BinIcon(type: bin) // re-uses your existing icon

            VStack(alignment: .leading, spacing: 2) {
                Text(bin.displayName)
                    .font(.subheadline.bold())

                Text(bin.detailText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct RecyclingHelpView_Previews: PreviewProvider {
    static var previews: some View {
        RecyclingHelpView()
    }
}
