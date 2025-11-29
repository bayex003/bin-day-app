import SwiftUI

struct UpcomingCalendarView: View {
    let collections: [BinCollection]

    @State private var displayedMonth: Date = Date()

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)

    // Group collections by day
    private var collectionsByDay: [Date: [BinCollection]] {
        Dictionary(grouping: collections) { collection in
            calendar.startOfDay(for: collection.date)
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            // Month header with arrows
            HStack {
                Button {
                    displayedMonth = previousMonth(from: displayedMonth)
                } label: {
                    Image(systemName: "chevron.left")
                }

                Spacer()

                Text(monthYearString(for: displayedMonth))
                    .font(.headline)

                Spacer()

                Button {
                    displayedMonth = nextMonth(from: displayedMonth)
                } label: {
                    Image(systemName: "chevron.right")
                }
            }
            .padding(.horizontal)

            // Weekday labels
            HStack {
                ForEach(weekdaySymbols(), id: \.self) { symbol in
                    Text(symbol)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 4)

            // Calendar grid
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(daysInMonthGrid(for: displayedMonth), id: \.self) { date in
                    DayCell(
                        date: date,
                        isInCurrentMonth: isInDisplayedMonth(date),
                        collections: collectionsByDay[calendar.startOfDay(for: date)] ?? []
                    )
                }
            }
            .padding(.horizontal, 4)

            Spacer()
        }
        .padding(.top, 12)
        .navigationTitle("Calendar")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Snap displayedMonth to the first of the month for consistency
            displayedMonth = startOfMonth(for: Date())
        }
    }

    // MARK: - Calendar helpers

    private func startOfMonth(for date: Date) -> Date {
        let comps = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: comps) ?? date
    }

    private func monthYearString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: date)
    }

    private func previousMonth(from date: Date) -> Date {
        guard let result = calendar.date(byAdding: .month, value: -1, to: date) else { return date }
        return startOfMonth(for: result)
    }

    private func nextMonth(from date: Date) -> Date {
        guard let result = calendar.date(byAdding: .month, value: 1, to: date) else { return date }
        return startOfMonth(for: result)
    }

    private func weekdaySymbols() -> [String] {
        // Short symbols starting from the current calendar's firstWeekday
        let symbols = calendar.shortWeekdaySymbols
        let first = calendar.firstWeekday - 1 // 0-based index
        return Array(symbols[first...] + symbols[..<first])
    }

    private func daysInMonthGrid(for baseDate: Date) -> [Date] {
        let monthStart = startOfMonth(for: baseDate)
        guard let range = calendar.range(of: .day, in: .month, for: monthStart) else {
            return []
        }

        // First weekday of the month (shifted to firstWeekday)
        let weekdayOfFirst = calendar.component(.weekday, from: monthStart)
        let offset = (weekdayOfFirst - calendar.firstWeekday + 7) % 7

        var days: [Date] = []

        // Add leading empty slots by going back into previous month
        if offset > 0 {
            for i in stride(from: offset, to: 0, by: -1) {
                if let date = calendar.date(byAdding: .day, value: -i, to: monthStart) {
                    days.append(date)
                }
            }
        }

        // Add all days of this month
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: monthStart) {
                days.append(date)
            }
        }

        // Fill the last row to complete a week (optional, cosmetic)
        while days.count % 7 != 0 {
            if let last = days.last,
               let next = calendar.date(byAdding: .day, value: 1, to: last) {
                days.append(next)
            }
        }

        return days
    }

    private func isInDisplayedMonth(_ date: Date) -> Bool {
        let m1 = calendar.dateComponents([.year, .month], from: displayedMonth)
        let m2 = calendar.dateComponents([.year, .month], from: date)
        return m1.year == m2.year && m1.month == m2.month
    }
}

// MARK: - Day cell

private struct DayCell: View {
    let date: Date
    let isInCurrentMonth: Bool
    let collections: [BinCollection]

    private let calendar = Calendar.current

    var body: some View {
        VStack(spacing: 4) {
            Text("\(dayNumber(for: date))")
                .font(.subheadline)
                .fontWeight(isToday(date) ? .bold : .regular)
                .foregroundColor(isInCurrentMonth ? .primary : .secondary.opacity(0.4))

            if !collections.isEmpty {
                HStack(spacing: 3) {
                    ForEach(colourDots(for: collections).prefix(3), id: \.self) { color in
                        Circle()
                            .fill(color)
                            .frame(width: 6, height: 6)
                    }
                }
            } else {
                Spacer(minLength: 6)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 40)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isToday(date) ? Color.blue.opacity(0.08) : Color.clear)
        )
    }

    private func dayNumber(for date: Date) -> Int {
        calendar.component(.day, from: date)
    }

    private func isToday(_ date: Date) -> Bool {
        calendar.isDateInToday(date)
    }

    // Map collections to dot colours based on bin type displayName
    private func colourDots(for collections: [BinCollection]) -> [Color] {
        let names = collections.map { $0.type.displayName.lowercased() }

        return names.map { name in
            if name.contains("food") {
                return Color.green
            } else if name.contains("garden") {
                // represent garden as yellow-ish or pink; pick one consistent colour
                return Color.pink
            } else if name.contains("blue") || name.contains("paper") || name.contains("card") {
                return Color.blue
            } else if name.contains("brown") || name.contains("bottle") || name.contains("can") || name.contains("plastic") {
                return Color.brown
            } else if name.contains("grey") || name.contains("gray") || name.contains("general") {
                return Color.gray
            } else {
                return Color.gray.opacity(0.7)
            }
        }
    }
}
