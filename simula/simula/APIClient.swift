import Foundation

struct APIClient {
    private let baseURL: URL
    private let session: URLSession

    init(baseURL: URL = SimulaConfig.apiBaseURL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    func send<T: Decodable>(
        _ endpoint: Endpoint,
        apiKey: String? = nil
    ) async throws -> T {
        let request = try makeRequest(endpoint, apiKey: apiKey)

        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                let payload = String(data: data, encoding: .utf8)
                if httpResponse.statusCode == 401 {
                    throw APIError.invalidAPIKey
                }
                throw APIError.httpError(statusCode: httpResponse.statusCode, payload: payload)
            }

            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                throw APIError.decodingError(error)
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }

    private func makeRequest(_ endpoint: Endpoint, apiKey: String?) throws -> URLRequest {
        guard let url = endpoint.url(baseURL: baseURL) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("1", forHTTPHeaderField: "ngrok-skip-browser-warning")

        if endpoint.requiresAuthorization, let apiKey {
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        }

        if let body = endpoint.body {
            request.httpBody = try JSONEncoder().encode(body)
        }

        return request
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

enum Endpoint {
    case createSession(devMode: Bool?, primaryUserID: String?)
    case fetchCatalog
    case initializeMinigame(InitMinigameRequestDTO)
    case fetchFallbackAd(adID: String)
    case trackMenuGameClick(menuID: String, gameName: String)

    var method: HTTPMethod {
        switch self {
        case .fetchCatalog:
            return .get
        case .createSession, .initializeMinigame, .fetchFallbackAd, .trackMenuGameClick:
            return .post
        }
    }

    var requiresAuthorization: Bool {
        switch self {
        case .createSession, .trackMenuGameClick:
            return true
        case .fetchCatalog, .initializeMinigame, .fetchFallbackAd:
            return false
        }
    }

    var body: EncodableBody? {
        switch self {
        case .createSession:
            return EncodableBody(payload: EmptyBody())
        case .initializeMinigame(let request):
            return EncodableBody(payload: request)
        case .trackMenuGameClick(let menuID, let gameName):
            return EncodableBody(payload: TrackMenuClickRequestDTO(menuID: menuID, gameName: gameName))
        case .fetchCatalog, .fetchFallbackAd:
            return nil
        }
    }

    func url(baseURL: URL) -> URL? {
        switch self {
        case .createSession(let devMode, let primaryUserID):
            var components = URLComponents(url: baseURL.appendingPathComponent("session/create"), resolvingAgainstBaseURL: false)
            var queryItems: [URLQueryItem] = []

            if let devMode {
                queryItems.append(URLQueryItem(name: "devMode", value: String(devMode)))
            }
            if let primaryUserID, !primaryUserID.isEmpty {
                queryItems.append(URLQueryItem(name: "ppid", value: primaryUserID))
            }

            components?.queryItems = queryItems.isEmpty ? nil : queryItems
            return components?.url
        case .fetchCatalog:
            return baseURL.appendingPathComponent("minigames/catalogv2")
        case .initializeMinigame:
            return baseURL.appendingPathComponent("minigames/init")
        case .fetchFallbackAd(let adID):
            return baseURL.appendingPathComponent("minigames/fallback_ad/\(adID)")
        case .trackMenuGameClick:
            return baseURL.appendingPathComponent("minigames/menu/track/click")
        }
    }
}

private struct EmptyBody: Encodable {}

struct EncodableBody: Encodable {
    private let encodeFunc: (Encoder) throws -> Void

    init<T: Encodable>(payload: T) {
        self.encodeFunc = payload.encode(to:)
    }

    func encode(to encoder: Encoder) throws {
        try encodeFunc(encoder)
    }
}
