import SwiftUI

#if os(iOS)
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

#Preview {
    OverlayCloseControl(isEnabled: true, action: {})
        .padding()
        .background(Color.black)
}
#endif
