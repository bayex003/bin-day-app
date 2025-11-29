import Combine
import MapKit
import SwiftUI

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

    // Services
    private let addressService = GetAddressService()
    private let addressStorage = AddressStorage.shared
    private let geocodingService = GeocodingService()
    private let scheduleService = BinScheduleService.shared
    private let recyclingLocator = RecyclingCentreLocator()
    private let notificationsManager = NotificationsManager.shared

    // Recycling centres
    @State private var nearestCentre: RecyclingCentre?
    @State private var nearestCentreDistance: CLLocationDistance?
    @State private var isFindingNearestCentre: Bool = false
    @State private var nearestCentreError: String?
    @State private var recyclingMapPosition: MapCameraPosition = .automatic
    @State private var addressCoordinate: CLLocationCoordinate2D?

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

                    Section("Nearest recycling centre") {
                        if isFindingNearestCentre {
                            HStack(spacing: 10) {
                                ProgressView()
                                Text("Finding the nearest recycling centre…")
                            }
                        } else if let error = nearestCentreError {
                            Label(error, systemImage: "exclamationmark.triangle.fill")
                                .foregroundStyle(.red)
                        } else if let centre = nearestCentre {
                            VStack(alignment: .leading, spacing: 8) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(centre.name)
                                        .font(.headline)

                                    Text(centre.address)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)

                                    if let distance = formattedNearestDistance {
                                        Label(distance, systemImage: "car.fill")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }

                                Map(position: $recyclingMapPosition) {
                                    if let coordinate = addressCoordinate {
                                        Annotation("You", coordinate: coordinate) {
                                            ZStack {
                                                Circle()
                                                    .fill(.blue.opacity(0.18))
                                                    .frame(width: 34, height: 34)
                                                Image(systemName: "house.fill")
                                                    .foregroundStyle(.blue)
                                                    .font(.subheadline)
                                            }
                                        }
                                    }

                                    Marker(centre.name, coordinate: centre.coordinate)
                                        .tint(.green)
                                }
                                .frame(height: 220)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .mapStyle(.standard(elevation: .realistic))
                            }
                            .padding(.vertical, 4)
                        } else {
                            Text("Select an address to find your closest recycling centre.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
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
                }

                if selectedAddress == nil {
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
                                    scheduleError = nil
                                    addressStorage.save(enriched)
                                    collections = []
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
            .onReceive(NotificationCenter.default.publisher(for: .addressDidClear)) { _ in
                selectedAddress = nil
                postcode = ""
                collections = []
                scheduleError = nil
                results = []
                searchErrorMessage = nil
                isLoadingSchedule = false
                nearestCentre = nil
                nearestCentreDistance = nil
                nearestCentreError = nil
                isFindingNearestCentre = false
                addressCoordinate = nil
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
        collections = []

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

    private var formattedNearestDistance: String? {
        guard let metres = nearestCentreDistance else {
            return nil
        }

        let measurement = Measurement(value: metres, unit: UnitLength.meters)
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        formatter.unitStyle = .medium
        formatter.numberFormatter.maximumFractionDigits = 1

        if metres >= 1_000 {
            return formatter.string(from: measurement.converted(to: .kilometers))
        } else {
            return formatter.string(from: measurement)
        }
    }

    private func loadNearestRecyclingCentre() {
        guard let selected = selectedAddress else {
            nearestCentre = nil
            nearestCentreDistance = nil
            nearestCentreError = nil
            addressCoordinate = nil
            return
        }

        isFindingNearestCentre = true
        nearestCentreError = nil
        nearestCentre = nil
        nearestCentreDistance = nil
        addressCoordinate = nil

        Task {
            do {
                let coordinate = try await geocodingService.coordinates(for: selected.postcode)
                guard let match = recyclingLocator.nearestCentre(to: coordinate) else {
                    await MainActor.run {
                        self.nearestCentreError = "No recycling centres available."
                        self.isFindingNearestCentre = false
                    }
                    return
                }

                let region = mapRegion(containing: [coordinate, match.centre.coordinate])

                await MainActor.run {
                    self.addressCoordinate = coordinate
                    self.nearestCentre = match.centre
                    self.nearestCentreDistance = match.distance
                    self.recyclingMapPosition = .region(region)
                    self.isFindingNearestCentre = false
                }
            } catch {
                await MainActor.run {
                    self.nearestCentreError = (error as? LocalizedError)?.errorDescription
                        ?? "Could not find a nearby recycling centre."
                    self.isFindingNearestCentre = false
                }
            }
        }
    }

    private func mapRegion(containing coordinates: [CLLocationCoordinate2D]) -> MKCoordinateRegion {
        guard let first = coordinates.first else {
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 53.483959, longitude: -2.244644),
                span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
            )
        }

        var minLat = first.latitude
        var maxLat = first.latitude
        var minLon = first.longitude
        var maxLon = first.longitude

        for coordinate in coordinates.dropFirst() {
            minLat = min(minLat, coordinate.latitude)
            maxLat = max(maxLat, coordinate.latitude)
            minLon = min(minLon, coordinate.longitude)
            maxLon = max(maxLon, coordinate.longitude)
        }

        let latitudeDelta = max((maxLat - minLat) * 1.4, 0.02)
        let longitudeDelta = max((maxLon - minLon) * 1.4, 0.02)

        let center = CLLocationCoordinate2D(
            latitude: (maxLat + minLat) / 2,
            longitude: (maxLon + minLon) / 2
        )

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
