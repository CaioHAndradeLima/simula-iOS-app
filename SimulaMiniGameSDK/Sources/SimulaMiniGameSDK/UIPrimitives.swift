import SwiftUI
import WebKit
#if canImport(UIKit)
import UIKit
#endif

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
        /// Solid modal shell (no alpha) — same look as old gradient over black, without backdrop bleed-through.
        static let modalCardFillTop = Color(red: 0.144, green: 0.158, blue: 0.216)
        static let modalCardFillBottom = Color(red: 0.094, green: 0.109, blue: 0.172)
        /// Opaque bottom “aura” (replaces translucent cyan radial).
        static let modalCardAura = Color(red: 0.10, green: 0.165, blue: 0.235)
        static let modalCardBorder = Color(red: 0.28, green: 0.30, blue: 0.36)
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

/// Full-screen layer behind the modal card: Maya artwork + 50% black dim. Card stays a separate opaque layer on top.
struct MenuBackdropView: View {
    let character: MiniGameCharacterContext
    var dimOverlayOpacity: Double = 0.5

    @State private var remoteImageFailed = false

    var body: some View {
        ZStack {
            backdropImage
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()

            Color.black.opacity(dimOverlayOpacity)
        }
        .ignoresSafeArea()
    }

    @ViewBuilder
    private var backdropImage: some View {
        if let img = packageImage(named: "MayaBackground") {
            img.resizable().scaledToFill()
        } else if let img = packageImage(named: "MayaCharacter") {
            img.resizable().scaledToFill()
        } else if let url = URL(string: character.charImage), !remoteImageFailed {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                case .failure:
                    DS.Colors.scrim.onAppear { remoteImageFailed = true }
                case .empty:
                    DS.Colors.scrim
                @unknown default:
                    DS.Colors.scrim
                }
            }
        } else {
            DS.Colors.scrim
        }
    }
}

struct MenuChrome<Content: View>: View {
    let character: MiniGameCharacterContext
    let content: Content
    let onClose: (() -> Void)?

    init(character: MiniGameCharacterContext, onClose: (() -> Void)? = nil, @ViewBuilder content: () -> Content) {
        self.character = character
        self.onClose = onClose
        self.content = content()
    }

    var body: some View {
        GeometryReader { geo in
            let cardWidth = geo.size.width < 768 ? geo.size.width * 0.92 : geo.size.width * 0.95
            let cardHeight = geo.size.width < 768 ? geo.size.height * 0.82 : geo.size.height * 0.90

            ZStack(alignment: .center) {
                MenuBackdropView(character: character, dimOverlayOpacity: 0.5)
                    .frame(width: geo.size.width, height: geo.size.height)

                HStack(spacing: 0) {
                    Spacer(minLength: 0)
                    VStack(spacing: DS.Spacing.small) {
                        if let onClose {
                            HStack {
                                Spacer()
                                OverlayCloseControl(isEnabled: true, action: onClose)
                            }
                            .padding(.top, 2)
                        }
                        content
                    }
                    .padding(.horizontal, DS.Spacing.medium)
                    .padding(.vertical, DS.Spacing.medium)
                    .frame(width: cardWidth, height: cardHeight)
                    .background(
                        ZStack {
                            LinearGradient(
                                colors: [DS.Colors.modalCardFillTop, DS.Colors.modalCardFillBottom],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            RadialGradient(
                                colors: [DS.Colors.modalCardAura, DS.Colors.modalCardFillBottom],
                                center: .bottom,
                                startRadius: 40,
                                endRadius: 380
                            )
                        }
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: DS.CornerRadius.modal)
                            .stroke(DS.Colors.modalCardBorder, lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: DS.CornerRadius.modal))
                    .shadow(color: .black.opacity(0.4), radius: 24, x: 0, y: 16)
                    Spacer(minLength: 0)
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct MenuHeaderView: View {
    let character: MiniGameCharacterContext
    @State private var imageFailed = false

    /// Width reference = 25% of screen; Maya / icon / disk percentages use this as `base`.
    private var clusterBaseWidth: CGFloat {
        UIScreen.main.bounds.width * 0.25
    }

    var body: some View {
        let base = clusterBaseWidth
        let clusterH = base
        let mayaSide = base * 0.8
        let iconSize = base * 0.6
        let diskDiameter = base
        let mayaY = (clusterH - mayaSide) / 2
        let mayaTrailing = mayaSide
        let iconCenterX = mayaTrailing
        let stickCenterY = mayaY + mayaSide / 2 - base * 0.06
        let layoutWidth = mayaTrailing + diskDiameter / 2

        HStack(alignment: .center, spacing: 12) {
            ZStack(alignment: .topLeading) {
                headerClusterBackgroundDisk(
                    diameter: diskDiameter,
                    centerX: iconCenterX,
                    centerY: stickCenterY
                )
                .zIndex(0)

                headerClusterGamestickIcon(
                    iconSize: iconSize,
                    centerX: iconCenterX,
                    centerY: stickCenterY
                )
                .zIndex(1)

                avatar(side: mayaSide, cornerRadius: mayaSide * (16 / 74))
                    .offset(x: 0, y: mayaY)
                    .zIndex(2)
            }
            .frame(width: layoutWidth, height: clusterH, alignment: .leading)

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

    private func headerClusterBackgroundDisk(diameter: CGFloat, centerX: CGFloat, centerY: CGFloat) -> some View {
        let diskTint = Color(red: 0.82, green: 0.28, blue: 0.78)
        let r = diameter / 2

        return Circle()
            .fill(
                RadialGradient(
                    gradient: Gradient(stops: [
                        .init(color: diskTint.opacity(0.15), location: 0),
                        .init(color: diskTint.opacity(0.15), location: 0.62),
                        .init(color: diskTint.opacity(0.05), location: 0.86),
                        .init(color: Color.clear, location: 1)
                    ]),
                    center: .center,
                    startRadius: 0,
                    endRadius: r
                )
            )
            .frame(width: diameter, height: diameter)
            .offset(x: centerX - diameter / 2, y: centerY - diameter / 2)
    }

    @ViewBuilder
    private func headerClusterGamestickIcon(iconSize: CGFloat, centerX: CGFloat, centerY: CGFloat) -> some View {
        let pinkCore = Color(red: 0.98, green: 0.32, blue: 0.62)

        if let icon = packageImage(named: "GameControlIcon") {
            icon
                .resizable()
                .renderingMode(.original)
                .scaledToFit()
                .frame(width: iconSize, height: iconSize)
                .shadow(color: pinkCore.opacity(0.38), radius: 5, x: 0, y: 0)
                .offset(x: centerX - iconSize / 2, y: centerY - iconSize / 2)
        }
    }

    @ViewBuilder
    private func avatar(side: CGFloat, cornerRadius: CGFloat) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(Color.white.opacity(0.09))
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
                .frame(width: side, height: side)

            if let bundledMaya = packageImage(named: "MayaCharacter"), !imageFailed {
                bundledMaya
                    .resizable()
                    .scaledToFill()
                    .frame(width: side, height: side)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            } else {
                if let url = URL(string: character.charImage), !imageFailed {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFill()
                        case .failure:
                            initials(side: side)
                                .onAppear { imageFailed = true }
                        case .empty:
                            ProgressView().tint(.white)
                        @unknown default:
                            initials(side: side)
                        }
                    }
                    .frame(width: side, height: side)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                } else {
                    initials(side: side)
                }
            }
        }
        .shadow(color: .black.opacity(0.35), radius: 10, x: 0, y: 6)
    }

    private func initials(side: CGFloat) -> some View {
        let parts = character.charName.split(separator: " ")
        let text = String(parts.prefix(2).map { $0.first.map(String.init) ?? "" }.joined())
        return Text(text.isEmpty ? "AI" : text.uppercased())
            .font(.system(size: max(14, side * 0.32), weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: side, height: side)
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

    private let diameter: CGFloat = 32

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color(white: 0.22).opacity(0.95))
                Circle()
                    .stroke(Color.white.opacity(0.52), lineWidth: 1.5)
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color(red: 0.94, green: 0.94, blue: 0.96))
            }
            .frame(width: diameter, height: diameter)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.55)
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
