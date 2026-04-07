import SwiftUI
import WebKit

#if os(iOS)
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
#endif
