import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int, payload: String?)
    case decodingError(Error)
    case networkError(Error)
    case invalidAPIKey

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL."
        case .invalidResponse:
            return "Invalid server response."
        case .httpError(let statusCode, _):
            return "HTTP error (\(statusCode))."
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network request failed: \(error.localizedDescription)"
        case .invalidAPIKey:
            return "Invalid API key. Please verify your Simula API key."
        }
    }
}
