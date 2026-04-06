import SwiftUI

struct MiniGameMenuView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @StateObject var viewModel: MiniGameMenuViewModel

    let characterName: String
    let onSelectGame: (MiniGame) -> Void

    var body: some View {
        VStack(spacing: MiniGameDS.Spacing.medium) {
            MiniGameHeaderView(title: "Play a Game with", subtitle: characterName)
                .padding(.top, MiniGameDS.Spacing.small)

            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(.horizontal, MiniGameDS.Spacing.medium)
        .padding(.bottom, MiniGameDS.Spacing.medium)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(MiniGameDS.Colors.background)
        .task {
            if viewModel.viewState == .idle {
                await viewModel.loadMenuCatalog()
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.viewState {
        case .idle, .loading:
            MiniGameLoadingView()
        case .empty:
            MiniGameEmptyOrErrorView(message: "No games are available to play right now. Please check back later!")
        case .error(let message):
            MiniGameEmptyOrErrorView(message: message)
        case .loaded:
            if horizontalSizeClass == .regular {
                iPadGrid
            } else {
                iPhoneCarousel
            }
        }
    }

    private var iPadGrid: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 24), count: 4)
        return ScrollView {
            LazyVGrid(columns: columns, spacing: 24) {
                ForEach(viewModel.games) { game in
                    MiniGameCardView(game: game) {
                        onSelectGame(game)
                    }
                }
            }
            .padding(.vertical, MiniGameDS.Spacing.small)
        }
    }

    private var iPhoneCarousel: some View {
        TabView {
            ForEach(viewModel.games) { game in
                MiniGameCardView(game: game) {
                    onSelectGame(game)
                }
                .padding(.horizontal, 28) // leaves side peek
                .padding(.vertical, MiniGameDS.Spacing.small)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
}
