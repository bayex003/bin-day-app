import SwiftUI
import MapKit
import CoreLocation

struct HomeView: View {
    @EnvironmentObject private var appState: AppState

    // Address search
    @State private var postcode: String = ""
    @State private var isSearching: Bool = false
    @State private var searchErrorMessage: String?
    @State private var results: [AddressItem] = []
    @State private var selectedAddress: AddressItem?

    // Bin schedule
    @State private var collections: [BinCollection] = []
    @State private var isLoadingSchedule: Bool = false
    @State private var scheduleError: String?

    // Nearest recycling centre
    @State private var addressCoordinate: CLLocationCoordinate2D?
    @State private var nearestCentre: RecyclingCentre?
    @State private var nearestCentreError: String?
    @State private var isLoadingNearestCentre: Bool = false
    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 53.4839, longitude: -2.2446),
        span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
    )

    // Services
    private let addressService = GetAddressService()
    private let addressStorage = AddressStorage.shared
    private let scheduleService = BinScheduleService.shared
    private let geocodingService = GeocodingService()
    private let recyclingCentreService = RecyclingCentreService()
    private let notificationsManager = NotificationsManager.shared

    // All bins for the next upcoming date
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
        NavigationStack {
            List {
                // HEADER
                Section {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Salford bins")
                            .font(.title2.bold())

                        Text("Check your next collection and get gentle reminders for your household.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }

                // SELECTED ADDRESS / INTRO
                Section {
                    if let selected = selectedAddress {
                        SelectedAddressCard(address: selected)
                    } else {
                        Text("Start by finding your Salford address using your postcode below.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                // NEXT COLLECTION
                if selectedAddress != nil {
                    Section {
                        NextCollectionCard(
                            isLoading: isLoadingSchedule,
                            error: scheduleError,
                            collections: collections
                        )
                    }

                    // UPCOMING CALENDAR LINK
                    if collections.count > nextDayCollections.count {
                        Section {
                            NavigationLink {
                                CollectionsCalendarView(collections: collections)
                            } label: {
                                Text("View upcoming collections")
                                    .font(.subheadline)
                                    .foregroundStyle(.tint)
                            }
                        }
                    }

                    Section("Nearest recycling centre") {
                        RecyclingCentreMapCard(
                            isLoading: isLoadingNearestCentre,
                            error: nearestCentreError,
                            addressCoordinate: addressCoordinate,
                            centre: nearestCentre,
                            region: $mapRegion
                        )
                    }
                }

                // SEARCH
                Section {
                    SearchCard(
                        postcode: $postcode,
                        isSearching: isSearching,
                        errorMessage: searchErrorMessage,
                        onSearch: searchTapped
                    )
                }

                // ADDRESS RESULTS
                if !results.isEmpty {
                    Section("Select your address") {
                        ForEach(results) { address in
                            Button {
                                var enriched = address

                                let trimmedPostcode = enriched.postcode
                                    .trimmingCharacters(in: .whitespacesAndNewlines)
                                    .uppercased()

                                // Hard-coded test UPRN for Salford demo
                                if trimmedPostcode == "M30 8HA" {
                                    enriched = AddressItem(
                                        id: enriched.id,
                                        label: enriched.label,
                                        postcode: enriched.postcode,
                                        uprn: "100011343156"
                                    )
                                }

                                selectedAddress = enriched
                                addressStorage.save(enriched)
                                loadSchedule()
                                loadNearestRecyclingCentre()
                                results = []
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(address.label)
                                            .font(.subheadline)
                                        Text(address.postcode)
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    if selectedAddress?.id == address.id {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(.green)
                                    } else {
                                        Image(systemName: "chevron.right")
                                            .foregroundStyle(.tertiary)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if let saved = addressStorage.load() {
                    selectedAddress = saved
                    postcode = saved.postcode
                    loadSchedule()
                    loadNearestRecyclingCentre()
                }
            }
        }
    }

    // MARK: - Actions

    private func searchTapped() {
        searchErrorMessage = nil
        results = []

        let query = postcode.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !query.isEmpty else {
            searchErrorMessage = "Enter a postcode to look up your address."
            return
        }

        isSearching = true

        Task {
            do {
                let addresses = try await addressService.search(postcode: query)
                await MainActor.run {
                    self.results = addresses
                    if self.results.isEmpty {
                        self.searchErrorMessage = "No addresses found for “\(query)”."
                    }
                    self.isSearching = false
                }
            } catch {
                await MainActor.run {
                    self.searchErrorMessage = (error as? LocalizedError)?.errorDescription
                        ?? "Something went wrong. Please try again."
                    self.isSearching = false
                }
            }
        }
    }

    private func loadSchedule() {
        guard let selected = selectedAddress else {
            collections = []
            scheduleError = nil
            return
        }

        isLoadingSchedule = true
        scheduleError = nil

        Task {
            do {
                let items = try await scheduleService.getSchedule(for: selected)
                await MainActor.run {
                    self.collections = items
                    self.isLoadingSchedule = false
                }

                if appState.notificationsEnabled {
                    await notificationsManager.scheduleNotifications(
                        for: items,
                        address: selected,
                        primaryEnabled: appState.primaryReminderEnabled,
                        secondaryEnabled: appState.secondaryReminderEnabled,
                        primaryTime: appState.primaryReminderTime,
                        secondaryTime: appState.secondaryReminderTime
                    )
                }
            } catch {
                await MainActor.run {
                    self.scheduleError = (error as? LocalizedError)?.errorDescription
                        ?? "Could not load bin schedule."
                    self.isLoadingSchedule = false
                }
            }
        }
    }

    private func loadNearestRecyclingCentre() {
        guard let selected = selectedAddress else {
            addressCoordinate = nil
            nearestCentre = nil
            nearestCentreError = nil
            return
        }

        isLoadingNearestCentre = true
        nearestCentreError = nil

        Task {
            do {
                let coordinate = try await geocodingService.coordinate(for: selected.postcode)
                let centre = recyclingCentreService.nearestCentre(to: coordinate)

                await MainActor.run {
                    self.addressCoordinate = coordinate
                    self.nearestCentre = centre

                    if let centreCoordinate = centre?.coordinate {
                        self.mapRegion = regionThatFits(address: coordinate, centre: centreCoordinate)
                    } else {
                        self.mapRegion = MKCoordinateRegion(
                            center: coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                        )
                    }

                    self.isLoadingNearestCentre = false
                }
            } catch {
                await MainActor.run {
                    self.nearestCentre = nil
                    self.addressCoordinate = nil
                    self.nearestCentreError = (error as? LocalizedError)?.errorDescription
                        ?? "Couldn't locate your postcode on the map."
                    self.isLoadingNearestCentre = false
                }
            }
        }
    }

    private func regionThatFits(address: CLLocationCoordinate2D, centre: CLLocationCoordinate2D) -> MKCoordinateRegion {
        let center = CLLocationCoordinate2D(
            latitude: (address.latitude + centre.latitude) / 2,
            longitude: (address.longitude + centre.longitude) / 2
        )

        let latitudeDelta = max(abs(address.latitude - centre.latitude) * 2.5, 0.05)
        let longitudeDelta = max(abs(address.longitude - centre.longitude) * 2.5, 0.05)

        return MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        )
    }
}

// MARK: - Components used by Home

private struct SelectedAddressCard: View {
    let address: AddressItem

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "house.fill")
                    .font(.subheadline)
                    .foregroundStyle(.tint)

                Text("Household address")
                    .font(.caption.smallCaps())
                    .foregroundStyle(.secondary)

                Spacer()
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(address.label)
                    .font(.headline)

                Text(address.postcode)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
        )
    }
}

private struct RecyclingCentreMapCard: View {
    let isLoading: Bool
    let error: String?
    let addressCoordinate: CLLocationCoordinate2D?
    let centre: RecyclingCentre?
    @Binding var region: MKCoordinateRegion

    private var annotationItems: [AnnotationItem] {
        var items: [AnnotationItem] = []

        if let coordinate = addressCoordinate {
            items.append(
                AnnotationItem(
                    title: "Your address",
                    coordinate: coordinate,
                    color: .blue,
                    systemImage: "house.fill"
                )
            )
        }

        if let centre = centre {
            items.append(
                AnnotationItem(
                    title: centre.name,
                    coordinate: centre.coordinate,
                    color: .green,
                    systemImage: "leaf.fill"
                )
            )
        }

        return items
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if isLoading {
                HStack(spacing: 10) {
                    ProgressView()
                    Text("Finding the nearest site…")
                        .font(.subheadline)
                }
            } else if let error = error {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(.red)
            } else if let centre = centre, addressCoordinate != nil {
                Map(coordinateRegion: $region, annotationItems: annotationItems) { item in
                    MapAnnotation(coordinate: item.coordinate) {
                        VStack(spacing: 6) {
                            Image(systemName: item.systemImage)
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Circle().fill(item.color))

                            Text(item.title)
                                .font(.caption2.bold())
                                .padding(.horizontal, 6)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .fill(Color(.systemBackground))
                                        .shadow(radius: 4)
                                )
                        }
                    }
                }
                .frame(height: 220)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                VStack(alignment: .leading, spacing: 6) {
                    Text(centre.name)
                        .font(.headline)

                    Text(centre.address)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text(centre.openingHours)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text("Green pin shows where to drop off recycling; blue pin is your address.")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            } else {
                Text("Enter a Salford postcode to see the nearest recycling centre on a map.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

private struct AnnotationItem: Identifiable {
    let id = UUID()
    let title: String
    let coordinate: CLLocationCoordinate2D
    let color: Color
    let systemImage: String
}

// MARK: - Search card

private struct SearchCard: View {
    @Binding var postcode: String
    let isSearching: Bool
    let errorMessage: String?
    let onSearch: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Postcode or address")
                .font(.headline)

            HStack(spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)

                    TextField("e.g. M30 8HA", text: $postcode)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                        .keyboardType(.asciiCapable)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(.secondarySystemBackground))
                )

                Button(action: onSearch) {
                    if isSearching {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Find")
                            .font(.subheadline.bold())
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSearching ? Color.gray : Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(12)
                .disabled(isSearching)
            }

            if let message = errorMessage {
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }
        }
        .padding(.vertical, 4)
    }
}
