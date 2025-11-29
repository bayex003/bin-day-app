import SwiftUI

struct CollectionsCalendarView: View {
    let collections: [BinCollection]

    @State private var displayedMonth: Date = Date()
    @State private var selectedDate: Date? = Date()

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)

    // Group collections by day
    private var collectionsByDay: [Date: [BinCollection]] {
        Dictionary(grouping: collections) { collection in
            calendar.startOfDay(for: collection.date)
        }
    }

    private var selectedCollections: [BinCollection] {
        guard let selected = selectedDate else { return [] }
        let key = calendar.startOfDay(for: selected)
        return (collectionsByDay[key] ?? [])
            .sorted { $0.type.displayName < $1.type.displayName }
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
                    let dayKey = calendar.startOfDay(for: date)
                    DayCell(
                        date: date,
                        isInCurrentMonth: isInDisplayedMonth(date),
                        collectionsForDay: collectionsByDay[dayKey] ?? [],
                        isSelected: isSameDay(date, selectedDate),
                        onTap: {
                            selectedDate = date
                        }
                    )
                }
            }
            .padding(.horizontal, 4)

            // Breakdown for selected day
            if let selected = selectedDate {
                VStack(alignment: .leading, spacing: 8) {
                    Text(dateString(for: selected))
                        .font(.headline)

                    if selectedCollections.isEmpty {
                        Text("No collections scheduled for this day.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(selectedCollections.indices, id: \.self) { index in
                            CalendarBinRow(collection: selectedCollections[index])
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 4)
            }

            Spacer()
        }
        .padding(.top, 12)
        .navigationTitle("Calendar")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            displayedMonth = startOfMonth(for: Date())
            if selectedDate == nil {
                selectedDate = Date()
            }
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

    private func dateString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE d MMMM"
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
        let symbols = calendar.shortWeekdaySymbols    // ["Sun", "Mon", ...]
        let first = calendar.firstWeekday - 1         // 0-based index
        return Array(symbols[first...] + symbols[..<first])
    }

    private func daysInMonthGrid(for baseDate: Date) -> [Date] {
        let monthStart = startOfMonth(for: baseDate)
        guard let range = calendar.range(of: .day, in: .month, for: monthStart) else {
            return []
        }

        let weekdayOfFirst = calendar.component(.weekday, from: monthStart)
        let offset = (weekdayOfFirst - calendar.firstWeekday + 7) % 7

        var days: [Date] = []

        // Leading days from previous month
        if offset > 0 {
            for i in stride(from: offset, to: 0, by: -1) {
                if let date = calendar.date(byAdding: .day, value: -i, to: monthStart) {
                    days.append(date)
                }
            }
        }

        // All days of current month
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: monthStart) {
                days.append(date)
            }
        }

        // Fill last row to full weeks
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

    private func isSameDay(_ lhs: Date, _ rhs: Date?) -> Bool {
        guard let rhs = rhs else { return false }
        return calendar.isDate(lhs, inSameDayAs: rhs)
    }
}

// MARK: - Day cell

private struct DayCell: View {
    let date: Date
    let isInCurrentMonth: Bool
    let collectionsForDay: [BinCollection]
    let isSelected: Bool
    let onTap: () -> Void

    private let calendar = Calendar.current

    var body: some View {
        VStack(spacing: 4) {
            Text("\(dayNumber(for: date))")
                .font(.subheadline)
                .fontWeight(isToday(date) || isSelected ? .bold : .regular)
                .foregroundColor(isInCurrentMonth ? .primary : .secondary.opacity(0.4))

            if !collectionsForDay.isEmpty {
                HStack(spacing: 3) {
                    ForEach(binColors(for: collectionsForDay).prefix(3), id: \.description) { color in
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
                .fill(backgroundColor)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }

    private var backgroundColor: Color {
        if isSelected {
            return Color.blue.opacity(0.15)
        } else if isToday(date) {
            return Color.blue.opacity(0.08)
        } else {
            return Color.clear
        }
    }

    private func dayNumber(for date: Date) -> Int {
        calendar.component(.day, from: date)
    }

    private func isToday(_ date: Date) -> Bool {
        calendar.isDateInToday(date)
    }

    private func binColors(for collections: [BinCollection]) -> [Color] {
        let names = collections.map { $0.type.displayName.lowercased() }

        return names.map { name in
            if name.contains("food") {
                return Color.green
            } else if name.contains("garden") {
                return Color.pink
            } else if name.contains("blue") || name.contains("paper") || name.contains("card") {
                return Color.blue
            } else if name.contains("brown") || name.contains("bottle") || name.contains("can") || name.contains("plastic") {
                return Color.brown
            } else if name.contains("grey") || name.contains("gray") || name.contains("general") {
                return Color.black
            } else {
                return Color.black.opacity(0.7)
            }
        }
    }
}

// MARK: - Breakdown row under calendar

private struct CalendarBinRow: View {
    let collection: BinCollection

    private var nameLower: String {
        collection.type.displayName.lowercased()
    }

    private var label: String {
        if nameLower.contains("food") {
            return "Food waste"
        } else if nameLower.contains("garden") {
            return "Garden waste"
        } else if nameLower.contains("blue") || nameLower.contains("paper") || nameLower.contains("card") {
            return "Blue bin"
        } else if nameLower.contains("brown") || nameLower.contains("bottle") || nameLower.contains("can") || nameLower.contains("plastic") {
            return "Brown bin"
        } else if nameLower.contains("black") || nameLower.contains("black") || nameLower.contains("general") {
            return "Black bin"
        } else {
            return collection.type.displayName
        }
    }

    private var color: Color {
        if nameLower.contains("food") {
            return Color.green
        } else if nameLower.contains("garden") {
            return Color.pink
        } else if nameLower.contains("blue") || nameLower.contains("paper") || nameLower.contains("card") {
            return Color.blue
        } else if nameLower.contains("brown") || nameLower.contains("bottle") || nameLower.contains("can") || nameLower.contains("plastic") {
            return Color.brown
        } else if nameLower.contains("grey") || nameLower.contains("gray") || nameLower.contains("general") {
            return Color.black
        } else {
            return Color.black.opacity(0.7)
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 6)
                .fill(color)
                .frame(width: 20, height: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.subheadline.bold())

                Text(collection.type.displayName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}
