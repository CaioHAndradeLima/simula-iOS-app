import SwiftUI

#if os(iOS)
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

#Preview {
    CountdownBadge(seconds: 4)
        .padding()
        .background(Color.black)
}
#endif
