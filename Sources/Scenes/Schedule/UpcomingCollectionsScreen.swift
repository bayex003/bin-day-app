import SwiftUI

/// Simple wrapper that just shows UpcomingCollectionsView with provided data
struct UpcomingCollectionsScreen: View {
    let collections: [BinCollection]

    var body: some View {
        UpcomingCalendarView(
            collections: collections
        )
    }
}
