import SwiftUI

#if os(iOS)
struct CardView: View {
    let game: MiniGame
    let onTap: () -> Void
    @State private var gifError = false
    @State private var iconError = false

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottomLeading) {
                background
                LinearGradient(colors: [.clear, .black.opacity(0.95)], startPoint: .center, endPoint: .bottom)
                Text(game.name).font(.system(size: 17, weight: .heavy)).foregroundStyle(.white).lineLimit(2).padding(10)
            }
            .aspectRatio(9 / 16, contentMode: .fit)
            .frame(minHeight: 300)
            .background(DS.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.white.opacity(0.12), lineWidth: 1.5))
            .shadow(color: .black.opacity(0.42), radius: 10, x: 0, y: 8)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder private var background: some View {
        let imageURL = (!gifError ? game.gifCover : nil) ?? (!iconError ? game.iconURL : nil)
        if let imageURL, let url = URL(string: imageURL) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image): image.resizable().scaledToFill().scaleEffect(1.04)
                case .failure: Color.clear.onAppear { if !gifError { gifError = true } else { iconError = true } }
                case .empty: ProgressView().tint(.white)
                @unknown default: Color.black
                }
            }
        } else {
            ZStack { Color.white.opacity(0.04); Text(game.iconFallback ?? "🎮").font(.system(size: 48)) }
        }
    }
}

#Preview {
    CardView(
        game: .init(
            id: "1",
            name: "Chess",
            iconURL: "https://example.com/icon.png",
            description: "Play chess",
            iconFallback: "♟️",
            gifCover: nil
        ),
        onTap: {}
    )
    .frame(width: 240, height: 420)
    .padding()
    .background(Color.black)
}
#endif
