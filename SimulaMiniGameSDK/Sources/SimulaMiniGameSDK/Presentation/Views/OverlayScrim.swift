import SwiftUI

#if os(iOS)
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
#endif
