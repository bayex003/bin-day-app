// Sources/Services/OSPlacesClient.swift
import Foundation

enum OSPlacesError: LocalizedError {
    case missingApiKey
    case badResponse
    case httpStatus(code: Int, body: String)
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .missingApiKey:
            return "No OS Places API key is configured."
        case .badResponse:
            return "The OS service returned an unexpected response."
        case .httpStatus(let code, let body):
            return "The OS service returned an error (code \(code)). \(body)"
        case .decodingFailed:
            return "Couldn’t read the data returned by the OS service."
        }
    }
}

/// Minimal decoding models for OS Places postcode endpoint
private struct OSPlacesResponse: Decodable {
    let results: [OSPlacesResult]
}

private struct OSPlacesResult: Decodable {
    let DPA: OSPlacesDPA?
}

private struct OSPlacesDPA: Decodable {
    let UPRN: String?
    let ADDRESS: String
    let POSTCODE: String?
}

/// Client for OS Places API – postcode → list of addresses
final class OSPlacesClient {

    static let shared = OSPlacesClient()
    private init() {}

    /// TODO: for production, don’t hard-code – load from a config file / keystore.
    /// For now, paste your key here while we’re developing:
    private let apiKey: String = "JxJ0lhhfgMIxAMxhMmjSYaAndbv0mKpm"

    private let session = URLSession.shared

    func lookup(postcode rawPostcode: String) async throws -> [OSAddress] {
        let trimmed = rawPostcode
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .uppercased()

        guard !trimmed.isEmpty else { return [] }
        guard !apiKey.isEmpty else { throw OSPlacesError.missingApiKey }

        var components = URLComponents(string: "https://api.os.uk/search/places/v1/postcode")!
        components.queryItems = [
            URLQueryItem(name: "postcode", value: trimmed),
            URLQueryItem(name: "key", value: apiKey)
        ]

        guard let url = components.url else {
            throw OSPlacesError.badResponse
        }

        let (data, response) = try await session.data(from: url)

        guard let http = response as? HTTPURLResponse else {
            throw OSPlacesError.badResponse
        }

        guard http.statusCode == 200 else {
            // Try to surface OS’s error message if present
            let bodyString = String(data: data, encoding: .utf8) ?? ""
            throw OSPlacesError.httpStatus(code: http.statusCode, body: bodyString)
        }

        let decoded: OSPlacesResponse
        do {
            decoded = try JSONDecoder().decode(OSPlacesResponse.self, from: data)
        } catch {
            throw OSPlacesError.decodingFailed
        }

        let addresses: [OSAddress] = decoded.results.compactMap { result in
            guard let dpa = result.DPA else { return nil }
            let uprn = dpa.UPRN ?? UUID().uuidString
            return OSAddress(
                id: uprn,
                label: dpa.ADDRESS,
                postcode: dpa.POSTCODE,
                uprn: dpa.UPRN
            )
        }

        return addresses
    }
}
