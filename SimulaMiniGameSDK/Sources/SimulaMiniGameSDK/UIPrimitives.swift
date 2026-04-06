import SwiftUI
import WebKit

#if os(iOS)
enum DS {
    enum Colors {
        static let background = Color(red: 0.043, green: 0.043, blue: 0.059)
        static let surface = Color.white.opacity(0.06)
        static let border = Color(red: 120 / 255, green: 200 / 255, blue: 255 / 255).opacity(0.12)
        static let primaryText = Color.white
        static let secondaryText = Color.white.opacity(0.75)
        static let overlay = Color.black.opacity(0.84)
        static let accent = Color(red: 59 / 255, green: 130 / 255, blue: 246 / 255)
        static let modalBackgroundTop = Color(red: 0.20, green: 0.22, blue: 0.30).opacity(0.72)
        static let modalBackgroundBottom = Color(red: 0.12, green: 0.14, blue: 0.22).opacity(0.78)
        static let scrim = Color.black.opacity(0.48)
    }

    enum Spacing {
        static let xSmall: CGFloat = 8
        static let small: CGFloat = 12
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
    }

    enum CornerRadius {
        static let modal: CGFloat = 24
        static let card: CGFloat = 18
    }
}

struct MenuChrome<Content: View>: View {
    let content: Content
    let onClose: (() -> Void)?

    init(onClose: (() -> Void)? = nil, @ViewBuilder content: () -> Content) {
        self.onClose = onClose
        self.content = content()
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                DS.Colors.scrim.ignoresSafeArea()

                VStack(spacing: DS.Spacing.small) {
                    if let onClose {
                        HStack {
                            Spacer()
                            OverlayCloseControl(isEnabled: true, action: onClose)
                                .frame(width: 28, height: 28)
                        }
                        .padding(.top, 2)
                    }
                    content
                }
                .padding(.horizontal, DS.Spacing.medium)
                .padding(.vertical, DS.Spacing.medium)
                .frame(
                    width: geo.size.width < 768 ? geo.size.width * 0.92 : geo.size.width * 0.95,
                    height: geo.size.width < 768 ? geo.size.height * 0.82 : geo.size.height * 0.90
                )
                .background(
                    ZStack {
                        // Subtle aura like the web modal background.
                        LinearGradient(
                            colors: [DS.Colors.modalBackgroundTop, DS.Colors.modalBackgroundBottom],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        RadialGradient(
                            colors: [Color.cyan.opacity(0.10), .clear],
                            center: .bottom,
                            startRadius: 60,
                            endRadius: 360
                        )
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: DS.CornerRadius.modal)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: DS.CornerRadius.modal))
                .shadow(color: .black.opacity(0.4), radius: 24, x: 0, y: 16)
            }
        }
    }
}

struct MenuHeaderView: View {
    let character: MiniGameCharacterContext
    @State private var imageFailed = false

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // Avatar + controller: glow sits behind; icon reads as neon on soft pink halo (web parity).
            ZStack(alignment: .leading) {
                controllerBadge
                    .zIndex(0)

                avatar
                    .zIndex(1)
            }
            .frame(width: 138, height: 90, alignment: .leading)

            VStack(alignment: .leading, spacing: 4) {
                Text("Play a Game with")
                    .font(.system(size: 20, weight: .black))
                    .foregroundStyle(DS.Colors.primaryText)
                Text(character.charName)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundStyle(DS.Colors.secondaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    /// Soft circular pink/magenta bloom + disk (not a purple pill); centered behind the avatar’s trailing edge so it bridges into the title area.
    private var controllerBadge: some View {
        let pinkCore = Color(red: 0.98, green: 0.32, blue: 0.62)
        let magentaEdge = Color(red: 0.72, green: 0.22, blue: 0.92)

        return ZStack {
            // Wide outer halo (reference: diffuse glow behind neon outline icon).
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            pinkCore.opacity(0.28),
                            magentaEdge.opacity(0.12),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 4,
                        endRadius: 52
                    )
                )
                .frame(width: 118, height: 118)
                .blur(radius: 14)

            // Inner readable disk (slightly opaque pink, still behind avatar).
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            pinkCore.opacity(0.16),
                            magentaEdge.opacity(0.08),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 2,
                        endRadius: 34
                    )
                )
                .frame(width: 78, height: 78)

            if let icon = packageImage(named: "GameControlIcon") {
                icon
                    .resizable()
                    .renderingMode(.original)
                    .scaledToFit()
                    .frame(width: 42, height: 42)
                    .shadow(color: pinkCore.opacity(0.38), radius: 5, x: 0, y: 0)
            }
        }
        .frame(width: 118, height: 118)
        // Shift so cluster sits behind the right side of the 74×74 avatar; center ~62pt from leading ≈ overlap + bridge to text.
        .offset(x: 22, y: -7)
    }

    @ViewBuilder
    private var avatar: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.09))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.12), lineWidth: 1))
                .frame(width: 74, height: 74)

            if let bundledMaya = packageImage(named: "MayaCharacter"), !imageFailed {
                bundledMaya
                    .resizable()
                    .scaledToFill()
                    .frame(width: 74, height: 74)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                if let url = URL(string: character.charImage), !imageFailed {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFill()
                        case .failure:
                            initials
                                .onAppear { imageFailed = true }
                        case .empty:
                            ProgressView().tint(.white)
                        @unknown default:
                            initials
                        }
                    }
                    .frame(width: 74, height: 74)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                } else {
                    initials
                }
            }
        }
        .shadow(color: .black.opacity(0.35), radius: 10, x: 0, y: 6)
    }

    private var initials: some View {
        let parts = character.charName.split(separator: " ")
        let text = String(parts.prefix(2).map { $0.first.map(String.init) ?? "" }.joined())
        return Text(text.isEmpty ? "AI" : text.uppercased())
            .font(.system(size: 24, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: 74, height: 74)
    }
}

struct StateView: View {
    let state: MiniGameMenuLifecycleState
    let retryAction: (() -> Void)?

    var body: some View {
        switch state {
        case .menuLoading, .gameLoading:
            VStack(spacing: DS.Spacing.small) {
                ProgressView().tint(.white).scaleEffect(1.2)
                Text(state == .gameLoading ? "Loading game..." : "Loading games...")
                    .foregroundStyle(DS.Colors.secondaryText)
                    .font(.system(size: 14, weight: .medium))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .menuEmpty:
            MessagePanel(icon: "gamecontroller", message: "No games are available to play right now. Please check back later!", retryAction: retryAction)
        case .menuError(let message):
            MessagePanel(icon: "exclamationmark.triangle", message: message, retryAction: retryAction)
        default:
            EmptyView()
        }
    }
}

private struct MessagePanel: View {
    let icon: String
    let message: String
    let retryAction: (() -> Void)?

    var body: some View {
        VStack(spacing: DS.Spacing.medium) {
            Image(systemName: icon)
                .font(.system(size: 42, weight: .semibold))
                .foregroundStyle(DS.Colors.secondaryText)

            Text(message)
                .foregroundStyle(DS.Colors.secondaryText)
                .font(.system(size: 14, weight: .medium))
                .multilineTextAlignment(.center)
                .padding(.horizontal, DS.Spacing.large)

            if let retryAction {
                Button("Try again", action: retryAction)
                    .buttonStyle(.borderedProminent)
                    .tint(DS.Colors.accent)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct OverlayCloseControl: View {
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark")
                .foregroundStyle(Color.white.opacity(0.82))
                .font(.system(size: 13, weight: .semibold))
                .frame(width: 32, height: 32)
                .background(Color.black.opacity(0.44))
                .overlay(
                    Circle().stroke(Color.white.opacity(0.24), lineWidth: 1)
                )
                .clipShape(Circle())
        }
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.6)
    }
}

struct CountdownBadge: View {
    let seconds: Int

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.black.opacity(0.46))
                .frame(width: 34, height: 34)
            Circle()
                .stroke(Color.white, lineWidth: 2.5)
                .frame(width: 34, height: 34)
            Text("\(seconds)")
                .foregroundStyle(.white)
                .font(.system(size: 14, weight: .semibold))
        }
        .accessibilityLabel("Ad closes in \(seconds) seconds")
    }
}

struct OverlayScrim: View {
    let canCloseByTap: Bool
    let onTap: () -> Void

    var body: some View {
        DS.Colors.overlay
            .ignoresSafeArea()
            .onTapGesture {
                if canCloseByTap {
                    onTap()
                }
            }
    }
}

struct OverlayLoadingView: View {
    let text: String

    var body: some View {
        ZStack {
            DS.Colors.overlay.ignoresSafeArea()
            VStack(spacing: DS.Spacing.small) {
                ProgressView()
                    .tint(.white)
                    .scaleEffect(1.2)
                Text(text)
                    .foregroundStyle(.white)
                    .font(.system(size: 17, weight: .semibold))
            }
        }
    }
}

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

struct WebOverlay: UIViewRepresentable {
    let url: URL
    func makeUIView(context: Context) -> WKWebView {
        let w = WKWebView(frame: .zero)
        w.scrollView.backgroundColor = .black
        return w
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if uiView.url != url { uiView.load(URLRequest(url: url)) }
    }
}

private struct CarouselCardCenterKey: PreferenceKey {
    static var defaultValue: [String: CGFloat] = [:]

    static func reduce(value: inout [String: CGFloat], nextValue: () -> [String: CGFloat]) {
        value.merge(nextValue(), uniquingKeysWith: { _, new in new })
    }
}

struct InteractiveMiniGameCarousel: View {
    let games: [MiniGame]
    let onSelect: (MiniGame) -> Void

    @State private var cardCenters: [String: CGFloat] = [:]

    var body: some View {
        GeometryReader { proxy in
            let containerWidth = proxy.size.width
            let containerCenterX = containerWidth / 2
            let cardWidth = max(220, min(318, containerWidth * 0.64))
            let horizontalInset = max(8, (containerWidth - cardWidth) / 2)

            ScrollViewReader { reader in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 14) {
                        ForEach(games) { game in
                            let scale = scaleForCard(
                                cardID: game.id,
                                centerX: containerCenterX,
                                cardWidth: cardWidth
                            )
                            let yLift = yOffsetForCard(
                                cardID: game.id,
                                centerX: containerCenterX,
                                cardWidth: cardWidth
                            )

                            CardView(game: game) {
                                onSelect(game)
                            }
                            .frame(width: cardWidth)
                            .scaleEffect(scale)
                            .offset(y: yLift)
                            .animation(.interactiveSpring(response: 0.26, dampingFraction: 0.86), value: cardCenters)
                            .background(
                                GeometryReader { cardGeo in
                                    Color.clear.preference(
                                        key: CarouselCardCenterKey.self,
                                        value: [game.id: cardGeo.frame(in: .named("SimulaCarouselSpace")).midX]
                                    )
                                }
                            )
                            .id(game.id)
                        }
                    }
                    .padding(.horizontal, horizontalInset)
                    .padding(.vertical, 14)
                }
                .coordinateSpace(name: "SimulaCarouselSpace")
                .onPreferenceChange(CarouselCardCenterKey.self) { value in
                    cardCenters = value
                }
                .simultaneousGesture(
                    DragGesture(minimumDistance: 4)
                        .onEnded { _ in
                            snapToNearest(reader: reader, containerCenterX: containerCenterX)
                        }
                )
                .onAppear {
                    guard let first = games.first else { return }
                    DispatchQueue.main.async {
                        reader.scrollTo(first.id, anchor: .center)
                    }
                }
            }
        }
    }

    private func snapToNearest(reader: ScrollViewProxy, containerCenterX: CGFloat) {
        guard let nearest = cardCenters.min(by: {
            abs($0.value - containerCenterX) < abs($1.value - containerCenterX)
        }) else {
            return
        }

        withAnimation(.spring(response: 0.30, dampingFraction: 0.88)) {
            reader.scrollTo(nearest.key, anchor: .center)
        }
    }

    private func scaleForCard(cardID: String, centerX: CGFloat, cardWidth: CGFloat) -> CGFloat {
        guard let cardMidX = cardCenters[cardID] else { return 0.90 }
        let distance = abs(cardMidX - centerX)
        let normalized = min(1.0, distance / (cardWidth * 0.95))
        // Center card = 1.00, side cards smoothly approach 0.86.
        return 1.0 - (0.14 * normalized)
    }

    private func yOffsetForCard(cardID: String, centerX: CGFloat, cardWidth: CGFloat) -> CGFloat {
        guard let cardMidX = cardCenters[cardID] else { return 8 }
        let distance = abs(cardMidX - centerX)
        let normalized = min(1.0, distance / (cardWidth * 0.95))
        // Center card is slightly raised; side cards sit lower.
        return -8 + (12 * normalized)
    }
}

private func packageImage(named name: String) -> Image? {
    #if SWIFT_PACKAGE
    return Image(name, bundle: .module)
    #else
    return nil
    #endif
}
#endif
