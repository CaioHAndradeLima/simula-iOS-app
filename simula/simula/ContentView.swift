//
//  ContentView.swift
//  simula
//
//  Created by Caio Henrique Andrade Lima on 06/04/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel: MiniGameMenuViewModel
    @State private var launchStatus = "Waiting for selection"
    @State private var adCloseCountdown: Int = 0
    @State private var adCountdownTask: Task<Void, Never>?

    init() {
        let provider = MiniGameProvider(apiKey: SimulaConfig.apiKey)
        let business = DefaultMiniGameBusinessLogic(provider: provider)
        _viewModel = StateObject(wrappedValue: MiniGameMenuViewModel(businessLogic: business))
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            MiniGameMenuView(
                viewModel: viewModel,
                characterName: "Maya",
                onSelectGame: { game in
                    Task {
                        await startGame(for: game)
                    }
                }
            )

            statusPanel
                .padding()
        }
        .overlay {
            if let gameURL = url(from: viewModel.gameIframeURL) {
                MiniGameOverlayView(
                    url: gameURL,
                    title: "game",
                    onClose: {
                        Task {
                            await closeGameFlow()
                        }
                    },
                    canCloseByBackdrop: true,
                    showCountdownSeconds: nil
                )
            } else if viewModel.isGameLoading, viewModel.selectedGame != nil {
                loadingOverlay
            }
        }
        .overlay {
            if let adURL = url(from: viewModel.fallbackAdIframeURL) {
                MiniGameOverlayView(
                    url: adURL,
                    title: "ad",
                    onClose: closeAdIfAllowed,
                    canCloseByBackdrop: adCloseCountdown == 0,
                    showCountdownSeconds: adCloseCountdown > 0 ? adCloseCountdown : nil
                )
                .onAppear {
                    startAdCountdown()
                }
                .onDisappear {
                    stopAdCountdown()
                }
            }
        }
    }

    private var statusPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("State: \(stateText(viewModel.viewState))")
            Text("Games loaded: \(viewModel.games.count)")
            Text("Game iframe ready: \(viewModel.gameIframeURL != nil ? "yes" : "no")")
            Text("Fallback ad ready: \(viewModel.fallbackAdIframeURL != nil ? "yes" : "no")")
            Text("Launch: \(launchStatus)")
        }
        .font(.system(size: 12, weight: .medium))
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.black.opacity(0.35))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func startGame(for game: MiniGame) async {
        launchStatus = "Initializing \(game.name)..."
        let screen = UIScreen.main.bounds

        await viewModel.selectGame(
            game,
            character: .init(
                charID: "char-123",
                charName: "Maya",
                charImage: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=512",
                charDescription: "AI companion"
            ),
            context: .init(
                conversationID: "conv-1",
                entryPoint: "ios-menu",
                messages: [.init(role: "user", content: "Let's play a game")],
                delegateCharacter: true,
                viewportWidth: Int(screen.width),
                viewportHeight: Int(screen.height)
            )
        )

        if viewModel.gameIframeURL != nil {
            launchStatus = "Playable URL received for \(game.name)"
        } else {
            launchStatus = "Failed to initialize \(game.name)"
        }
    }

    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.75)
                .ignoresSafeArea()
            VStack(spacing: 12) {
                ProgressView()
                    .tint(.white)
                    .scaleEffect(1.2)
                Text("Loading game...")
                    .foregroundStyle(.white)
                    .font(.system(size: 17, weight: .semibold))
            }
        }
    }

    private func closeGameFlow() async {
        launchStatus = "Closing game..."
        let willShowAd = await viewModel.closeGameAndMaybeShowFallbackAd()
        launchStatus = willShowAd ? "Showing fallback ad..." : "Game closed without fallback ad"
    }

    private func closeAdIfAllowed() {
        guard adCloseCountdown == 0 else { return }
        viewModel.closeFallbackAd()
        launchStatus = "Fallback ad closed"
    }

    private func startAdCountdown() {
        stopAdCountdown()
        adCloseCountdown = 5
        adCountdownTask = Task {
            while adCloseCountdown > 0 {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                if Task.isCancelled { return }
                adCloseCountdown -= 1
            }
        }
    }

    private func stopAdCountdown() {
        adCountdownTask?.cancel()
        adCountdownTask = nil
        adCloseCountdown = 0
    }

    private func url(from value: String?) -> URL? {
        guard let value, !value.isEmpty else { return nil }
        return URL(string: value)
    }

    private func stateText(_ state: MiniGameMenuViewModel.ViewState) -> String {
        switch state {
        case .idle: return "idle"
        case .loading: return "loading"
        case .loaded: return "loaded"
        case .empty: return "empty"
        case .error(let message): return "error (\(message))"
        }
    }
}

#Preview {
    ContentView()
}
