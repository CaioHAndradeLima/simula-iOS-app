import SwiftUI

struct MiniGameHeaderView: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 20, weight: .heavy))
                .foregroundStyle(MiniGameDS.Colors.textPrimary)
            Text(subtitle)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(MiniGameDS.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct MiniGameCardView: View {
    let game: MiniGame
    let onTap: () -> Void

    @State private var hasGifError = false
    @State private var hasIconError = false
    @State private var randomFallback = ["🎲", "🎮", "🎰", "🧩", "🎯"].randomElement() ?? "🎮"

    private var displayImageURL: String? {
        if !hasGifError, let gif = game.gifCover, !gif.isEmpty {
            return gif
        }
        if !hasIconError {
            return game.iconURL
        }
        return nil
    }

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottomLeading) {
                cardBackground

                LinearGradient(
                    colors: [MiniGameDS.Colors.overlayGradientTop, MiniGameDS.Colors.overlayGradientBottom],
                    startPoint: .center,
                    endPoint: .bottom
                )
                .clipShape(RoundedRectangle(cornerRadius: MiniGameDS.Radius.card))

                Text(game.name)
                    .font(.system(size: 17, weight: .heavy))
                    .foregroundStyle(MiniGameDS.Colors.textPrimary)
                    .lineLimit(2)
                    .padding(10)
            }
            .aspectRatio(9 / 16, contentMode: .fit)
            .frame(minHeight: 302)
            .background(MiniGameDS.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: MiniGameDS.Radius.card))
            .overlay(
                RoundedRectangle(cornerRadius: MiniGameDS.Radius.card)
                    .stroke(MiniGameDS.Colors.border, lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.4), radius: 12, x: 0, y: 8)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var cardBackground: some View {
        if let imageURL = displayImageURL, let url = URL(string: imageURL) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .scaleEffect(1.04)
                case .failure:
                    Color.clear
                        .onAppear {
                            if !hasGifError {
                                hasGifError = true
                            } else {
                                hasIconError = true
                            }
                        }
                case .empty:
                    ProgressView()
                        .tint(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.white.opacity(0.04))
                @unknown default:
                    Color.white.opacity(0.04)
                }
            }
        } else {
            ZStack {
                Color.white.opacity(0.04)
                Text(game.iconFallback ?? randomFallback)
                    .font(.system(size: 48))
            }
        }
    }
}

struct MiniGameLoadingView: View {
    var body: some View {
        VStack(spacing: MiniGameDS.Spacing.small) {
            ProgressView()
                .tint(.white)
                .scaleEffect(1.2)
            Text("Loading games...")
                .foregroundStyle(MiniGameDS.Colors.textSecondary)
                .font(.system(size: 14, weight: .medium))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct MiniGameEmptyOrErrorView: View {
    let message: String

    var body: some View {
        VStack(spacing: MiniGameDS.Spacing.medium) {
            Image(systemName: "gamecontroller")
                .font(.system(size: 44))
                .foregroundStyle(MiniGameDS.Colors.textSecondary)
            Text(message)
                .foregroundStyle(MiniGameDS.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .font(.system(size: 14, weight: .medium))
                .padding(.horizontal, MiniGameDS.Spacing.large)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
