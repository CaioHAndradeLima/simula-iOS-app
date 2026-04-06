import Foundation

protocol MiniGameBusinessLogic: Sendable {
    func ensureSessionIfNeeded() async throws -> String
    func loadCatalog() async throws -> (menuID: String?, games: [MiniGame])
    func trackMenuClick(menuID: String, gameName: String) async
    func initializeGame(
        gameID: String,
        sessionID: String,
        menuID: String?,
        character: MiniGameCharacterContext,
        context: MiniGameLaunchContext
    ) async throws -> MiniGameLaunchResult
    func fetchFallbackAdURL(adID: String) async throws -> String?
}

actor MiniGameSessionStore {
    private(set) var sessionID: String?
}

struct DefaultMiniGameBusinessLogic: MiniGameBusinessLogic {
    private let provider: MiniGameProviderProtocol
    private let sessionStore: MiniGameSessionStore
    private let devMode: Bool
    private let primaryUserID: String?

    init(
        provider: MiniGameProviderProtocol,
        sessionStore: MiniGameSessionStore = MiniGameSessionStore(),
        devMode: Bool = false,
        primaryUserID: String? = nil
    ) {
        self.provider = provider
        self.sessionStore = sessionStore
        self.devMode = devMode
        self.primaryUserID = primaryUserID
    }

    func ensureSessionIfNeeded() async throws -> String {
        if let existing = await sessionStore.sessionID {
            return existing
        }

        let sessionID = try await provider.createSession(devMode: devMode, primaryUserID: primaryUserID)
        await setSessionID(sessionID)
        return sessionID
    }

    func loadCatalog() async throws -> (menuID: String?, games: [MiniGame]) {
        let response = try await provider.fetchCatalog()
        return (response.menuID, response.games.map { $0.toDomain() })
    }

    func trackMenuClick(menuID: String, gameName: String) async {
        await provider.trackMenuGameClick(menuID: menuID, gameName: gameName)
    }

    func initializeGame(
        gameID: String,
        sessionID: String,
        menuID: String?,
        character: MiniGameCharacterContext,
        context: MiniGameLaunchContext
    ) async throws -> MiniGameLaunchResult {
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

        let response = try await provider.initializeMinigame(request)
        return MiniGameLaunchResult(
            gameIframeURL: response.adResponse.iframeURL,
            adID: response.adResponse.adID
        )
    }

    func fetchFallbackAdURL(adID: String) async throws -> String? {
        try await provider.fetchFallbackAdIframeURL(adID: adID)
    }

    private func setSessionID(_ sessionID: String) async {
        await sessionStore.setSessionID(sessionID)
    }
}

private extension MiniGameSessionStore {
    func setSessionID(_ value: String) {
        sessionID = value
    }
}
