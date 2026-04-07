import Foundation

protocol MiniGameProviderProtocol: Sendable {
    func createSession(devMode: Bool?, primaryUserID: String?) async throws -> String
    func fetchCatalog() async throws -> (menuID: String?, games: [GameDTO])
    func initialize(_ request: InitMinigameRequestDTO) async throws -> MinigameResponseDTO
    func fallbackAdURL(adID: String) async throws -> String?
    func trackMenuClick(menuID: String, gameName: String) async
}

struct MiniGameProvider: MiniGameProviderProtocol {
    let client: APIClient
    let apiKey: String

    func createSession(devMode: Bool?, primaryUserID: String?) async throws -> String {
        let response: SessionResponseDTO = try await client.send(.createSession(devMode: devMode, primaryUserID: primaryUserID), apiKey: apiKey)
        return response.sessionID
    }

    func fetchCatalog() async throws -> (menuID: String?, games: [GameDTO]) {
        let response: CatalogResponseDTO = try await client.send(.fetchCatalog, apiKey: nil)
        return (response.menuID, response.games)
    }

    func initialize(_ request: InitMinigameRequestDTO) async throws -> MinigameResponseDTO {
        try await client.send(.initializeMinigame(request), apiKey: nil)
    }

    func fallbackAdURL(adID: String) async throws -> String? {
        let response: MinigameResponseDTO = try await client.send(.fallbackAd(adID: adID), apiKey: nil)
        return response.adResponse.iframeURL
    }

    func trackMenuClick(menuID: String, gameName: String) async {
        struct Empty: Decodable {}
        do {
            let _: Empty = try await client.send(.trackMenuClick(menuID: menuID, gameName: gameName), apiKey: apiKey)
        } catch {
            // best effort
        }
    }
}

actor SessionStore {
    private(set) var sessionID: String?
    func setSessionID(_ value: String) { sessionID = value }
}

protocol MiniGameBusinessLogicProtocol: Sendable {
    func ensureSession() async throws -> String
    func catalog() async throws -> (menuID: String?, games: [MiniGame])
    func initializeGame(
        gameID: String,
        menuID: String?,
        character: MiniGameCharacterContext,
        context: MiniGameLaunchContext
    ) async throws -> (gameURL: String, adID: String)
    func fallbackAdURL(adID: String) async throws -> String?
    func trackMenuClick(menuID: String, gameName: String) async
}

struct MiniGameBusinessLogic: Sendable, MiniGameBusinessLogicProtocol {
    let provider: MiniGameProviderProtocol
    let sessionStore: SessionStore
    let config: SimulaMiniGameConfiguration

    init(config: SimulaMiniGameConfiguration) {
        self.config = config
        self.sessionStore = SessionStore()
        self.provider = MiniGameProvider(client: APIClient(baseURL: config.baseURL), apiKey: config.apiKey)
    }

    func ensureSession() async throws -> String {
        if let existing = await sessionStore.sessionID { return existing }
        let session = try await provider.createSession(devMode: config.devMode, primaryUserID: config.primaryUserID)
        await sessionStore.setSessionID(session)
        return session
    }

    func catalog() async throws -> (menuID: String?, games: [MiniGame]) {
        let result = try await provider.fetchCatalog()
        return (result.menuID, result.games.map { $0.toDomain() })
    }

    func initializeGame(
        gameID: String,
        menuID: String?,
        character: MiniGameCharacterContext,
        context: MiniGameLaunchContext
    ) async throws -> (gameURL: String, adID: String) {
        let sessionID = try await ensureSession()
        let request = InitMinigameRequestDTO(
            gameType: gameID,
            sessionID: sessionID,
            convID: context.conversationID,
            entryPoint: context.entryPoint,
            currencyMode: false,
            width: context.viewportWidth,
            height: context.viewportHeight,
            charID: character.charID,
            charName: character.charName,
            charImage: character.charImage,
            charDescription: character.charDescription,
            messages: context.messages,
            delegateChar: context.delegateCharacter,
            menuID: menuID
        )
        let response = try await provider.initialize(request)
        return (response.adResponse.iframeURL, response.adResponse.adID)
    }

    func fallbackAdURL(adID: String) async throws -> String? {
        try await provider.fallbackAdURL(adID: adID)
    }

    func trackMenuClick(menuID: String, gameName: String) async {
        await provider.trackMenuClick(menuID: menuID, gameName: gameName)
    }
}
