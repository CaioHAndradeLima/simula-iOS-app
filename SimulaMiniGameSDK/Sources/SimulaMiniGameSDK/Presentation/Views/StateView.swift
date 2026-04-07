import SwiftUI

#if os(iOS)
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

#Preview {
    StateView(state: .menuError("Network error"), retryAction: {})
        .frame(height: 280)
        .background(Color.black)
}
#endif
