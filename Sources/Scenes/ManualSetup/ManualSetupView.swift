import SwiftUI

struct ManualSetupView: View {
    @Environment(\.dismiss) private var dismiss

    // Address
    @State private var addressLine1 = ""
    @State private var addressLine2 = ""
    @State private var town = ""
    @State private var postcode = ""

    // Bin config – basic example
    @State private var binName = ""
    @State private var selectedColor: Color = .black
    @State private var nextCollectionDate = Date()
    @State private var recurrence: Recurrence = .weekly

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Address Details")) {
                    TextField("House number and street", text: $addressLine1)
                    TextField("Address line 2 (optional)", text: $addressLine2)
                    TextField("Town / City", text: $town)
                    TextField("Postcode", text: $postcode)
                        .textInputAutocapitalization(.characters)
                }

                Section(header: Text("First Bin Configuration")) {
                    TextField("Bin name, e.g. General Waste", text: $binName)

                    ColorPicker("Bin colour", selection: $selectedColor)

                    DatePicker("Next collection date",
                               selection: $nextCollectionDate,
                               displayedComponents: .date)

                    Picker("Recurrence", selection: $recurrence) {
                        ForEach(Recurrence.allCases, id: \.self) { option in
                            Text(option.displayName).tag(option)
                        }
                    }
                }

                Section {
                    Button(role: .none) {
                        saveAndClose()
                    } label: {
                        Text("Save & Continue")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .disabled(binName.isEmpty || postcode.isEmpty)
                }
            }
            .navigationTitle("Manual Setup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func saveAndClose() {
        // TODO: Save address + bin config into your data layer (e.g. BinStore)
        // For example:
        // let schedule = BinSchedule( ... )
        // binStore.add(schedule)

        dismiss()
    }
}

enum Recurrence: String, CaseIterable {
    case weekly
    case fortnightly

    var displayName: String {
        switch self {
        case .weekly: return "Weekly"
        case .fortnightly: return "Every 2 Weeks"
        }
    }
}
