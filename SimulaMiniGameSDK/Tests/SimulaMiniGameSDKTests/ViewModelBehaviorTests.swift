import XCTest
@testable import SimulaMiniGameSDK

final class ViewModelBehaviorTests: XCTestCase {
    func testLoadCatalogTransitionsToLoaded() async {
        let game = MiniGame(
            id: "g1",
            name: "Memory",
            iconURL: "https://example.com/icon.png",
            description: "desc",
            iconFallback: nil,
            gifCover: nil
        )
        let business = MockBusiness(
            ensureSessionResult: .success("session-1"),
            catalogResult: .success((menuID: "menu-1", games: [game]))
        )

        let vm = await MainActor.run {
            MiniGameMenuViewModel(business: business, callbacks: .init())
        }

        await vm.loadCatalog()

        let state = await MainActor.run { vm.state }
        let games = await MainActor.run { vm.games }
        XCTAssertEqual(state, .menuLoaded)
        XCTAssertEqual(games.count, 1)
    }

    func testSelectGameCallsOnGameOpenAndShowsGame() async {
        let game = MiniGame(
            id: "g1",
            name: "Memory",
            iconURL: "https://example.com/icon.png",
            description: "desc",
            iconFallback: nil,
            gifCover: nil
        )
        let business = MockBusiness(
            ensureSessionResult: .success("session-1"),
            catalogResult: .success((menuID: "menu-1", games: [game])),
            initializeResult: .success((gameURL: "https://example.com/game", adID: "ad-1"))
        )

        let callbackProbe = CallbackProbe()
        let vm = await MainActor.run {
            MiniGameMenuViewModel(
                business: business,
                callbacks: .init(
                    onGameOpen: { _ in callbackProbe.gameOpened += 1 },
                    onGameClose: { _ in callbackProbe.gameClosed += 1 },
                    onError: nil
                )
            )
        }

        await vm.loadCatalog()
        await vm.selectGame(
            game,
            character: .init(charID: "char", charName: "Maya", charImage: "https://example.com/char.png"),
            context: .init(viewportWidth: 390, viewportHeight: 844)
        )

        let state = await MainActor.run { vm.state }
        let gameURL = await MainActor.run { vm.gameURL }
        XCTAssertEqual(state, .gameShowing)
        XCTAssertEqual(gameURL, "https://example.com/game")
        XCTAssertEqual(callbackProbe.gameOpened, 1)
        XCTAssertEqual(callbackProbe.gameClosed, 0)
    }

    func testCloseGameFetchesFallbackAdOnlyOnce() async {
        let game = MiniGame(
            id: "g1",
            name: "Memory",
            iconURL: "https://example.com/icon.png",
            description: "desc",
            iconFallback: nil,
            gifCover: nil
        )
        let business = MockBusiness(
            ensureSessionResult: .success("session-1"),
            catalogResult: .success((menuID: "menu-1", games: [game])),
            initializeResult: .success((gameURL: "https://example.com/game", adID: "ad-1")),
            fallbackResult: .success("https://example.com/fallback")
        )

        let vm = await MainActor.run {
            MiniGameMenuViewModel(business: business, callbacks: .init())
        }

        await vm.loadCatalog()
        await vm.selectGame(
            game,
            character: .init(charID: "char", charName: "Maya", charImage: "https://example.com/char.png"),
            context: .init(viewportWidth: 390, viewportHeight: 844)
        )

        let first = await vm.closeGame()
        let second = await vm.closeGame()

        let adURL = await MainActor.run { vm.adURL }
        XCTAssertTrue(first)
        XCTAssertFalse(second)
        XCTAssertEqual(adURL, "https://example.com/fallback")
    }
}

private final class CallbackProbe: @unchecked Sendable {
    var gameOpened = 0
    var gameClosed = 0
}

private struct MockBusiness: MiniGameBusinessLogicProtocol {
    var ensureSessionResult: Result<String, Error> = .success("session")
    var catalogResult: Result<(menuID: String?, games: [MiniGame]), Error> = .success((menuID: nil, games: []))
    var initializeResult: Result<(gameURL: String, adID: String), Error> = .failure(MockError.notConfigured)
    var fallbackResult: Result<String?, Error> = .success(nil)

    func ensureSession() async throws -> String { try ensureSessionResult.get() }
    func catalog() async throws -> (menuID: String?, games: [MiniGame]) { try catalogResult.get() }
    func initializeGame(
        gameID: String,
        menuID: String?,
        character: MiniGameCharacterContext,
        context: MiniGameLaunchContext
    ) async throws -> (gameURL: String, adID: String) {
        try initializeResult.get()
    }
    func fallbackAdURL(adID: String) async throws -> String? { try fallbackResult.get() }
    func trackMenuClick(menuID: String, gameName: String) async {}
}

private enum MockError: Error {
    case notConfigured
}
