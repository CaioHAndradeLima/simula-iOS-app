import SwiftUI

#if os(iOS)
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
#endif
