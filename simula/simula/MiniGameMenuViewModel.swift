import Foundation
import SwiftUI
import Combine

@MainActor
final class MiniGameMenuViewModel: ObservableObject {
    enum ViewState: Equatable {
        case idle
        case loading
        case loaded
        case empty
        case error(String)
    }

    @Published private(set) var viewState: ViewState = .idle
    @Published private(set) var games: [MiniGame] = []
    @Published private(set) var menuID: String?

    @Published private(set) var selectedGame: MiniGame?
    @Published private(set) var gameIframeURL: String?
    @Published private(set) var gameAdID: String?
    @Published private(set) var fallbackAdIframeURL: String?
    @Published private(set) var isGameLoading = false

    private var didFetchAdForCurrentGame = false
    private let businessLogic: MiniGameBusinessLogic

    init(businessLogic: MiniGameBusinessLogic) {
        self.businessLogic = businessLogic
    }

    func loadMenuCatalog() async {
        viewState = .loading
        do {
            _ = try await businessLogic.ensureSessionIfNeeded()
            let result = try await businessLogic.loadCatalog()
            menuID = result.menuID
            games = result.games
            viewState = games.isEmpty ? .empty : .loaded
        } catch {
            viewState = .error(error.localizedDescription)
        }
    }

    func selectGame(
        _ game: MiniGame,
        character: MiniGameCharacterContext,
        context: MiniGameLaunchContext
    ) async {
        selectedGame = game
        gameIframeURL = nil
        fallbackAdIframeURL = nil
        gameAdID = nil
        didFetchAdForCurrentGame = false
        isGameLoading = true

        if let menuID {
            Task {
                await businessLogic.trackMenuClick(menuID: menuID, gameName: game.name)
            }
        }

        do {
            let sessionID = try await businessLogic.ensureSessionIfNeeded()
            let launch = try await businessLogic.initializeGame(
                gameID: game.id,
                sessionID: sessionID,
                menuID: menuID,
                character: character,
                context: context
            )

            gameIframeURL = launch.gameIframeURL
            gameAdID = launch.adID
            isGameLoading = false
        } catch {
            isGameLoading = false
            viewState = .error(error.localizedDescription)
        }
    }

    /// Called when user closes playable. Returns `true` when fallback ad should be shown.
    func closeGameAndMaybeShowFallbackAd() async -> Bool {
        guard !didFetchAdForCurrentGame else {
            selectedGame = nil
            gameIframeURL = nil
            return false
        }

        didFetchAdForCurrentGame = true
        guard let adID = gameAdID else {
            selectedGame = nil
            gameIframeURL = nil
            return false
        }

        do {
            if let adURL = try await businessLogic.fetchFallbackAdURL(adID: adID) {
                fallbackAdIframeURL = adURL
                selectedGame = nil
                gameIframeURL = nil
                return true
            }
        } catch {
            // No-op: if ad fetch fails, game flow should close gracefully.
        }

        selectedGame = nil
        gameIframeURL = nil
        return false
    }

    func closeFallbackAd() {
        fallbackAdIframeURL = nil
        gameAdID = nil
        selectedGame = nil
    }
}
