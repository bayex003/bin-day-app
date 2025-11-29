// Sources/Services/GetAddressService.swift
import Foundation

// MARK: - API Models

private struct GetAddressAutocompleteResponse: Codable {
    let suggestions: [GetAddressSuggestion]
}

private struct GetAddressSuggestion: Codable {
    let address: String
    let id: String
    let url: String
}

// MARK: - Error

enum GetAddressError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case noData

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Could not create request."
        case .invalidResponse:
            return "Invalid response from address service."
        case .httpError(let code):
            return "Address service error (code \(code))."
        case .noData:
            return "No data returned from address service."
        }
    }
}

// MARK: - Service

final class GetAddressService {

    private let apiKey: String

    init() {
        // Read from Info.plist
        if let key = Bundle.main.object(forInfoDictionaryKey: "GETADDRESS_API_KEY") as? String {
            self.apiKey = key
        } else {
            // Crash early in dev if you forget to set it
            fatalError("GETADDRESS_API_KEY is missing from Info.plist")
        }
    }

    /// Searches getAddress.io using the Autocomplete endpoint.
    /// You can pass a postcode or partial address.
    func search(postcode: String) async throws -> [AddressItem] {
        let term = postcode
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .uppercased()

        guard !term.isEmpty else {
            throw GetAddressError.invalidURL
        }

        // Encode for URL path: "M30 8HA" -> "M30%208HA"
        guard let encodedTerm = term.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            throw GetAddressError.invalidURL
        }

        let urlString = "https://api.getAddress.io/autocomplete/\(encodedTerm)"

        guard var components = URLComponents(string: urlString) else {
            throw GetAddressError.invalidURL
        }

        components.queryItems = [
            URLQueryItem(name: "api-key", value: apiKey)
        ]

        guard let url = components.url else {
            throw GetAddressError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let http = response as? HTTPURLResponse else {
            throw GetAddressError.invalidResponse
        }

        guard http.statusCode == 200 else {
            if let body = String(data: data, encoding: .utf8) {
                print("getAddress.io error \(http.statusCode): \(body)")
            }
            throw GetAddressError.httpError(http.statusCode)
        }

        let decoded = try JSONDecoder().decode(GetAddressAutocompleteResponse.self, from: data)

        // Map suggestions -> AddressItem for the UI
        let items = decoded.suggestions.map { suggestion -> AddressItem in
            AddressItem(
                label: suggestion.address,
                postcode: term // keep the original term as postcode for now
            )
        }

        return items
    }
}
