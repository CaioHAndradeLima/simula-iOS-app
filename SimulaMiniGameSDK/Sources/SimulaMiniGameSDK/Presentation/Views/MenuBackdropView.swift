import SwiftUI

#if os(iOS)
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

            // Extra bottom falloff like the web reference: transparent at top, solid black at bottom.
            LinearGradient(
                colors: [Color.black.opacity(0), Color.black.opacity(0.9)],
                startPoint: .top,
                endPoint: .bottom
            )
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

#Preview {
    MenuBackdropView(character: .init(charID: "1", charName: "Maya", charImage: "https://example.com/maya.png"))
}
#endif
