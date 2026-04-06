import SwiftUI

#if os(iOS)
public struct SimulaMiniGameMenuSDKView: View {
    @Environment(\.horizontalSizeClass) private var sizeClass
    @StateObject private var vm: MiniGameMenuViewModel

    private let character: MiniGameCharacterContext
    private let contextBuilder: (CGSize) -> MiniGameLaunchContext
    @State private var adCountdown = 0
    @State private var adTask: Task<Void, Never>?
    @State private var isMenuVisible = true

    public init(
        configuration: SimulaMiniGameConfiguration,
        character: MiniGameCharacterContext,
        callbacks: SimulaMiniGameCallbacks = .init(),
        contextBuilder: @escaping (CGSize) -> MiniGameLaunchContext
    ) {
        self.character = character
        self.contextBuilder = contextBuilder
        _vm = StateObject(wrappedValue: MiniGameMenuViewModel(business: MiniGameBusinessLogic(config: configuration), callbacks: callbacks))
    }

    public var body: some View {
        GeometryReader { geo in
            ZStack {
                if isMenuVisible {
                    MenuChrome(character: character, onClose: {
                        isMenuVisible = false
                    }) {
                        VStack(spacing: DS.Spacing.small) {
                            MenuHeaderView(character: character)
                            content(size: geo.size)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .task { if vm.state == .idle { await vm.loadCatalog() } }
            .overlay { gameOverlay(size: geo.size) }
            .overlay { adOverlay() }
        }
    }

    @ViewBuilder
    private func content(size: CGSize) -> some View {
        switch vm.state {
        case .idle, .menuLoading, .menuEmpty, .menuError:
            StateView(state: vm.state) {
                Task { await vm.loadCatalog() }
            }
        case .menuLoaded, .gameLoading, .gameShowing, .adShowing:
            if sizeClass == .regular {
                let cols = Array(repeating: GridItem(.flexible(), spacing: DS.Spacing.large), count: 4)
                ScrollView {
                    LazyVGrid(columns: cols, spacing: DS.Spacing.large) {
                        ForEach(vm.games) { game in
                            CardView(game: game) {
                                Task { await vm.selectGame(game, character: character, context: contextBuilder(size)) }
                            }
                            .frame(width: regularCardWidth(for: size.width))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            } else {
                InteractiveMiniGameCarousel(games: vm.games) { game in
                    Task { await vm.selectGame(game, character: character, context: contextBuilder(size)) }
                }
            }
        }
    }

    @ViewBuilder
    private func gameOverlay(size: CGSize) -> some View {
        if let urlString = vm.gameURL, let url = URL(string: urlString) {
            ZStack(alignment: .topTrailing) {
                OverlayScrim(canCloseByTap: true) {
                    Task { _ = await vm.closeGame() }
                }
                WebOverlay(url: url).ignoresSafeArea()
                OverlayCloseControl(isEnabled: true) {
                    Task { _ = await vm.closeGame() }
                }
                .padding(.top, DS.Spacing.medium)
                .padding(.trailing, DS.Spacing.medium)
            }
        } else if vm.state == .gameLoading || vm.isLoadingGame {
            OverlayLoadingView(text: "Loading game...")
        }
    }

    @ViewBuilder
    private func adOverlay() -> some View {
        if let urlString = vm.adURL, let url = URL(string: urlString) {
            ZStack(alignment: .topTrailing) {
                OverlayScrim(canCloseByTap: adCountdown == 0) {
                    if adCountdown == 0 {
                        vm.closeAd()
                    }
                }
                WebOverlay(url: url).ignoresSafeArea()
                Group {
                    if adCountdown > 0 {
                        CountdownBadge(seconds: adCountdown)
                    } else {
                        OverlayCloseControl(isEnabled: true) {
                            vm.closeAd()
                        }
                    }
                }
                .padding(.top, DS.Spacing.medium)
                .padding(.trailing, DS.Spacing.medium)
            }
            .onAppear { startAdCountdown() }
            .onDisappear { stopAdCountdown() }
        }
    }

    private func startAdCountdown() {
        stopAdCountdown()
        adCountdown = 5
        adTask = Task {
            while adCountdown > 0 {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                if Task.isCancelled { return }
                await MainActor.run {
                    adCountdown -= 1
                }
            }
        }
    }

    private func stopAdCountdown() {
        adTask?.cancel()
        adTask = nil
        adCountdown = 0
    }

    private func regularCardWidth(for totalWidth: CGFloat) -> CGFloat {
        let totalSpacing = DS.Spacing.large * 3
        let horizontalPadding = DS.Spacing.medium * 2
        let available = max(300, totalWidth - totalSpacing - horizontalPadding)
        return max(150, min(240, available / 4))
    }
}
#else
public struct SimulaMiniGameMenuSDKView: View {
    public init(
        configuration: SimulaMiniGameConfiguration,
        character: MiniGameCharacterContext,
        callbacks: SimulaMiniGameCallbacks = .init(),
        contextBuilder: @escaping (CGSize) -> MiniGameLaunchContext
    ) {}

    public var body: some View {
        Text("SimulaMiniGameSDK is currently supported on iOS.")
            .padding()
    }
}
#endif
