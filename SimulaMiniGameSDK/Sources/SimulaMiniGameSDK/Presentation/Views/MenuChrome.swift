import SwiftUI

#if os(iOS)
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
#endif
