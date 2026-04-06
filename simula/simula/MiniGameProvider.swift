import Foundation

protocol MiniGameProviderProtocol: Sendable {
    func createSession(devMode: Bool?, primaryUserID: String?) async throws -> String
    func fetchCatalog() async throws -> MiniGameCatalogResult
    func initializeMinigame(_ request: InitMinigameRequestDTO) async throws -> MinigameResponseDTO
    func fetchFallbackAdIframeURL(adID: String) async throws -> String?
    func trackMenuGameClick(menuID: String, gameName: String) async
}

struct MiniGameProvider: MiniGameProviderProtocol {
    private let apiClient: APIClient
    private let apiKey: String

    init(apiClient: APIClient = APIClient(), apiKey: String) {
        self.apiClient = apiClient
        self.apiKey = apiKey
    }

    func createSession(devMode: Bool?, primaryUserID: String?) async throws -> String {
        let response: SessionResponseDTO = try await apiClient.send(
            .createSession(devMode: devMode, primaryUserID: primaryUserID),
            apiKey: apiKey
        )
        return response.sessionID
    }

    func fetchCatalog() async throws -> MiniGameCatalogResult {
        let response: CatalogResponseDTO = try await apiClient.send(.fetchCatalog)
        return MiniGameCatalogResult(menuID: response.menuID, games: response.games)
    }

    func initializeMinigame(_ request: InitMinigameRequestDTO) async throws -> MinigameResponseDTO {
        try await apiClient.send(.initializeMinigame(request))
    }

    func fetchFallbackAdIframeURL(adID: String) async throws -> String? {
        let response: MinigameResponseDTO = try await apiClient.send(.fetchFallbackAd(adID: adID))
        return response.adResponse.iframeURL
    }

    func trackMenuGameClick(menuID: String, gameName: String) async {
        do {
            let _: EmptyTrackingResponse = try await apiClient.send(
                .trackMenuGameClick(menuID: menuID, gameName: gameName),
                apiKey: apiKey
            )
        } catch {
            // Tracking is best-effort by design; failures should never block UI flow.
        }
    }
}

private struct EmptyTrackingResponse: Decodable {}
