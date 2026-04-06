import SwiftUI
import WebKit

struct MiniGameWebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.scrollView.isScrollEnabled = true
        webView.backgroundColor = .black
        webView.isOpaque = false
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        if webView.url != url {
            let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)
            webView.load(request)
        }
    }
}

struct OverlayCloseButton: View {
    let action: () -> Void
    var isEnabled: Bool = true
    var label: String = "Close"

    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
                .background(Color.black.opacity(0.65))
                .clipShape(Circle())
        }
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.6)
        .accessibilityLabel(label)
    }
}

struct CountdownCloseBadge: View {
    let seconds: Int

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.black.opacity(0.45))
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

struct MiniGameOverlayView: View {
    let url: URL
    let title: String
    let onClose: () -> Void
    let canCloseByBackdrop: Bool
    let showCountdownSeconds: Int?

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .onTapGesture {
                    if canCloseByBackdrop {
                        onClose()
                    }
                }

            MiniGameWebView(url: url)
                .ignoresSafeArea()

            Group {
                if let seconds = showCountdownSeconds, seconds > 0 {
                    CountdownCloseBadge(seconds: seconds)
                } else {
                    OverlayCloseButton(action: onClose, isEnabled: true, label: "Close \(title)")
                }
            }
            .padding(.top, 16)
            .padding(.trailing, 16)
        }
    }
}
