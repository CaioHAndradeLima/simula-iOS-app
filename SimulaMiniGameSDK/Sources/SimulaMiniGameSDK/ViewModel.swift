import Foundation
import Combine

@MainActor
final class MiniGameMenuViewModel: ObservableObject {
    @Published private(set) var state: MiniGameMenuLifecycleState = .idle
    @Published private(set) var games: [MiniGame] = []
    @Published private(set) var gameURL: String?
    @Published private(set) var adURL: String?
    @Published private(set) var isLoadingGame = false

    private(set) var menuID: String?
    private(set) var activeGame: MiniGame?
    private var currentAdID: String?
    private var didShowFallbackAd = false
    private var isClosingGame = false
    private let business: MiniGameBusinessLogicProtocol
    private let callbacks: SimulaMiniGameCallbacks

    init(business: MiniGameBusinessLogicProtocol, callbacks: SimulaMiniGameCallbacks) {
        self.business = business
        self.callbacks = callbacks
    }

    func loadCatalog() async {
        state = .menuLoading
        do {
            _ = try await business.ensureSession()
            let result = try await business.catalog()
            menuID = result.menuID
            games = result.games
            state = games.isEmpty ? .menuEmpty : .menuLoaded
        } catch {
            reportError(error.localizedDescription)
        }
    }

    func selectGame(_ game: MiniGame, character: MiniGameCharacterContext, context: MiniGameLaunchContext) async {
        activeGame = game
        isLoadingGame = true
        state = .gameLoading
        gameURL = nil
        adURL = nil
        didShowFallbackAd = false
        isClosingGame = false
        if let menuID {
            Task { await business.trackMenuClick(menuID: menuID, gameName: game.name) }
        }
        do {
            let result = try await business.initializeGame(gameID: game.id, menuID: menuID, character: character, context: context)
            gameURL = result.gameURL
            currentAdID = result.adID
            state = .gameShowing
            callbacks.onGameOpen?(game)
        } catch {
            reportError(error.localizedDescription)
        }
        isLoadingGame = false
    }

    func closeGame() async -> Bool {
        guard !isClosingGame else { return false }
        isClosingGame = true
        defer { isClosingGame = false }

        guard !didShowFallbackAd, let currentAdID else {
            gameURL = nil
            finalizeGameClose()
            return false
        }
        didShowFallbackAd = true
        gameURL = nil
        do {
            if let ad = try await business.fallbackAdURL(adID: currentAdID) {
                adURL = ad
                state = .adShowing
                return true
            }
        } catch {
            // Keep behavior parity: ad fetch failures should not block closing the game.
        }
        finalizeGameClose()
        return false
    }

    func closeAd() {
        adURL = nil
        currentAdID = nil
        finalizeGameClose()
    }

    private func finalizeGameClose() {
        if let activeGame {
            callbacks.onGameClose?(activeGame)
        }
        activeGame = nil
        if games.isEmpty {
            state = .menuEmpty
        } else {
            state = .menuLoaded
        }
    }

    private func reportError(_ message: String) {
        state = .menuError(message)
        callbacks.onError?(message)
    }
}
