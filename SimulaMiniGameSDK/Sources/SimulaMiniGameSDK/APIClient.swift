import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case http(Int)
    case invalidAPIKey
    case decoding(Error)
    case network(Error)
}

enum HTTPMethod: String { case get = "GET", post = "POST" }

struct EncodableBody: Encodable {
    private let f: (Encoder) throws -> Void
    init<T: Encodable>(_ value: T) { f = value.encode(to:) }
    func encode(to encoder: Encoder) throws { try f(encoder) }
}

private struct EmptyBody: Encodable {}

enum Endpoint {
    case createSession(devMode: Bool?, primaryUserID: String?)
    case fetchCatalog
    case initializeMinigame(InitMinigameRequestDTO)
    case fallbackAd(adID: String)
    case trackMenuClick(menuID: String, gameName: String)

    var method: HTTPMethod {
        switch self {
        case .fetchCatalog: return .get
        default: return .post
        }
    }

    var requiresAuth: Bool {
        switch self {
        case .createSession, .trackMenuClick: return true
        default: return false
        }
    }

    var body: EncodableBody? {
        switch self {
        case .createSession: return EncodableBody(EmptyBody())
        case .initializeMinigame(let r): return EncodableBody(r)
        case .trackMenuClick(let m, let g): return EncodableBody(TrackMenuClickRequestDTO(menuID: m, gameName: g))
        default: return nil
        }
    }

    func url(baseURL: URL) -> URL? {
        switch self {
        case .createSession(let devMode, let ppid):
            var c = URLComponents(url: baseURL.appendingPathComponent("session/create"), resolvingAgainstBaseURL: false)
            var items: [URLQueryItem] = []
            if let devMode { items.append(URLQueryItem(name: "devMode", value: String(devMode))) }
            if let ppid, !ppid.isEmpty { items.append(URLQueryItem(name: "ppid", value: ppid)) }
            c?.queryItems = items.isEmpty ? nil : items
            return c?.url
        case .fetchCatalog:
            return baseURL.appendingPathComponent("minigames/catalogv2")
        case .initializeMinigame:
            return baseURL.appendingPathComponent("minigames/init")
        case .fallbackAd(let adID):
            return baseURL.appendingPathComponent("minigames/fallback_ad/\(adID)")
        case .trackMenuClick:
            return baseURL.appendingPathComponent("minigames/menu/track/click")
        }
    }
}

struct APIClient {
    let baseURL: URL
    let session: URLSession

    init(baseURL: URL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    func send<T: Decodable>(_ endpoint: Endpoint, apiKey: String?) async throws -> T {
        guard let url = endpoint.url(baseURL: baseURL) else { throw APIError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("1", forHTTPHeaderField: "ngrok-skip-browser-warning")
        if endpoint.requiresAuth, let apiKey {
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        }
        if let body = endpoint.body { request.httpBody = try JSONEncoder().encode(body) }

        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }
            guard (200...299).contains(http.statusCode) else {
                if http.statusCode == 401 { throw APIError.invalidAPIKey }
                throw APIError.http(http.statusCode)
            }
            do { return try JSONDecoder().decode(T.self, from: data) }
            catch { throw APIError.decoding(error) }
        } catch let e as APIError {
            throw e
        } catch {
            throw APIError.network(error)
        }
    }
}
