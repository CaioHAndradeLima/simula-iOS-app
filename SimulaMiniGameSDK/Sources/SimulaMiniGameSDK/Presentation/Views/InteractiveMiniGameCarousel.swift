import SwiftUI

#if os(iOS)
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
                    .applyCarouselTargetLayout()
                }
                .coordinateSpace(name: "SimulaCarouselSpace")
                .onPreferenceChange(CarouselCardCenterKey.self) { value in
                    cardCenters = value
                }
                .applyNaturalCarouselPaging()
                .onAppear {
                    guard let first = games.first else { return }
                    DispatchQueue.main.async {
                        reader.scrollTo(first.id, anchor: .center)
                    }
                }
            }
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

#Preview {
    InteractiveMiniGameCarousel(
        games: [
            .init(id: "1", name: "Chess", iconURL: "", description: "", iconFallback: "♟️", gifCover: nil),
            .init(id: "2", name: "Roulette", iconURL: "", description: "", iconFallback: "🎯", gifCover: nil),
            .init(id: "3", name: "Flappy Fishy", iconURL: "", description: "", iconFallback: "🐟", gifCover: nil)
        ],
        onSelect: { _ in }
    )
    .frame(height: 420)
    .background(Color.black)
}
#endif
