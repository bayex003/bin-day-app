import Foundation

// MARK: - Errors

enum BinScheduleError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case parseError
    case missingUPRN

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Could not build the bin schedule URL."
        case .invalidResponse:
            return "The bin schedule service returned an invalid response."
        case .httpError(let code):
            return "Bin schedule service error (code \(code))."
        case .parseError:
            return "Could not read the bin schedule from Salford Council."
        case .missingUPRN:
            return "No property ID (UPRN) found for this address."
        }
    }
}

// MARK: - Service

/// Salford-only bin schedule service. Uses Salford City Council's public ICS feed.
final class BinScheduleService {

    static let shared = BinScheduleService()
    private init() {}

    /// Main entry point used by the app.
    func getSchedule(for address: AddressItem) async throws -> [BinCollection] {
        guard let uprn = address.uprn, !uprn.isEmpty else {
            throw BinScheduleError.missingUPRN
        }

        let all = try await fetchSalfordSchedule(uprn: uprn)

        // Only keep today and future dates
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        let upcoming = all.filter { collection in
            calendar.startOfDay(for: collection.date) >= today
        }

        let sorted = upcoming.sorted { $0.date < $1.date }

        if sorted.isEmpty {
            throw BinScheduleError.parseError
        }

        return sorted
    }

    // MARK: - Salford ICS

    private func fetchSalfordSchedule(uprn: String) async throws -> [BinCollection] {
        let base = "https://www.salford.gov.uk/umbraco/api/salfordapi/GetBinCollectionsICS/"
        var components = URLComponents(string: base)
        components?.queryItems = [URLQueryItem(name: "UPRN", value: uprn)]

        guard let url = components?.url else {
            throw BinScheduleError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let http = response as? HTTPURLResponse else {
            throw BinScheduleError.invalidResponse
        }

        guard http.statusCode == 200 else {
            throw BinScheduleError.httpError(http.statusCode)
        }

        guard let text = String(data: data, encoding: .utf8) else {
            throw BinScheduleError.parseError
        }

        let parsed = parseICS(text)

        if parsed.isEmpty {
            throw BinScheduleError.parseError
        }

        return parsed
    }

    // MARK: - ICS parsing

    /// Parse Salford's ICS text into BinCollection models.
    /// IMPORTANT: one SUMMARY can produce *multiple* BinCollection entries
    /// for the same date (e.g. food + garden + blue recycling).
    private func parseICS(_ text: String) -> [BinCollection] {
        let lines = text.components(separatedBy: .newlines)

        var events: [[String]] = []
        var current: [String] = []
        var inEvent = false

        for rawLine in lines {
            let trimmed = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)

            if trimmed.hasPrefix("BEGIN:VEVENT") {
                inEvent = true
                current = []
            } else if trimmed.hasPrefix("END:VEVENT") {
                if inEvent && !current.isEmpty {
                    events.append(current)
                }
                inEvent = false
            } else if inEvent {
                // Handle folded lines (continuation starting with space)
                if let last = current.last, rawLine.hasPrefix(" ") {
                    current[current.count - 1] = last + rawLine.trimmingCharacters(in: .whitespaces)
                } else {
                    current.append(trimmed)
                }
            }
        }

        var result: [BinCollection] = []

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

        for event in events {
            var dtStartRaw: String?
            var summaryRaw: String?

            for line in event {
                if line.hasPrefix("DTSTART") {
                    if let colon = line.firstIndex(of: ":") {
                        let value = line[line.index(after: colon)...]
                        dtStartRaw = String(value)
                    }
                } else if line.hasPrefix("SUMMARY") {
                    if let colon = line.firstIndex(of: ":") {
                        let value = line[line.index(after: colon)...]
                        summaryRaw = String(value)
                    }
                }
            }

            guard
                let dateStr = dtStartRaw,
                let date = dateFormatter.date(from: String(dateStr.prefix(8))),
                let summary = summaryRaw
            else {
                continue
            }

            let types = mapSalfordSummaryToBinTypes(summary)
            guard !types.isEmpty else { continue }

            for type in types {
                result.append(BinCollection(id: UUID(), date: date, type: type))
            }
        }

        // De-duplicate (same bin type on same date)
        var unique: [BinCollection] = []
        var seen = Set<String>()
        let calendar = Calendar.current

        for item in result {
            let day = calendar.startOfDay(for: item.date).timeIntervalSince1970
            let key = "\(day)-\(item.type.rawValue)"

            if !seen.contains(key) {
                seen.insert(key)
                unique.append(item)
            }
        }

        return unique.sorted { $0.date < $1.date }
    }

    /// Map Salford ICS SUMMARY text to one or more BinType values.
    /// This handles lines like:
    /// - "Domestic waste (black bin), food and garden waste ... and recycling (blue bin)"
    /// - "Food and garden waste (pink lidded bin or outdoor caddy)"
    /// - "Blue recycling (paper and card)"
    /// - "Brown recycling (bottles and cans)"
    private func mapSalfordSummaryToBinTypes(_ summary: String) -> [BinType] {
        let s = summary.lowercased()
        var types: [BinType] = []

        // GENERAL / DOMESTIC / BLACK BIN
        if s.contains("general waste")
            || s.contains("domestic waste")
            || s.contains("black bin") {
            types.append(.general)
        }

        // FOOD + GARDEN combined -> we show as *two* rows: Food + Garden
        if s.contains("food and garden")
            || (s.contains("food") && s.contains("garden"))
            || s.contains("pink lidded")
            || s.contains("outdoor caddy") {

            types.append(.food)
            types.append(.garden)
        } else {
            // If only "food waste" appears on its own
            if s.contains("food waste") {
                types.append(.food)
            }
            // If only "garden waste" appears on its own
            if s.contains("garden waste") {
                types.append(.garden)
            }
        }

        // BLUE RECYCLING
        if s.contains("blue bin")
            || s.contains("blue recycling")
            || s.contains("paper and card") {
            types.append(.recyclingBlue)
        }

        // BROWN RECYCLING
        if s.contains("brown bin")
            || s.contains("brown recycling")
            || s.contains("bottles and cans")
            || (s.contains("bottles") && s.contains("cans")) {
            types.append(.recyclingBrown)
        }

        // Fallback: plain "recycling" with no colour – treat as brown
        if s.contains("recycling")
            && !types.contains(.recyclingBlue)
            && !types.contains(.recyclingBrown) {
            types.append(.recyclingBrown)
        }

        // Deduplicate
        var unique: [BinType] = []
        for t in types {
            if !unique.contains(t) {
                unique.append(t)
            }
        }
        return unique
    }
}
