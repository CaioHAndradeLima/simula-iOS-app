import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

#if os(iOS)
struct MenuHeaderView: View {
    let character: MiniGameCharacterContext
    @State private var imageFailed = false

    /// Width reference = 25% of screen; Maya / icon / disk percentages use this as `base`.
    private var clusterBaseWidth: CGFloat {
        UIScreen.main.bounds.width * 0.25
    }

    var body: some View {
        let base = clusterBaseWidth
        let clusterH = base
        let mayaSide = base * 0.8
        let iconSize = base * 0.6
        let diskDiameter = base
        let mayaY = (clusterH - mayaSide) / 2
        let mayaTrailing = mayaSide
        let iconCenterX = mayaTrailing
        let stickCenterY = mayaY + mayaSide / 2 - base * 0.06
        let layoutWidth = mayaTrailing + diskDiameter / 2

        HStack(alignment: .center, spacing: 12) {
            ZStack(alignment: .topLeading) {
                headerClusterBackgroundDisk(
                    diameter: diskDiameter,
                    centerX: iconCenterX,
                    centerY: stickCenterY
                )
                .zIndex(0)

                headerClusterGamestickIcon(
                    iconSize: iconSize,
                    centerX: iconCenterX,
                    centerY: stickCenterY
                )
                .zIndex(1)

                avatar(side: mayaSide, cornerRadius: mayaSide * (16 / 74))
                    .offset(x: 0, y: mayaY)
                    .zIndex(2)
            }
            .frame(width: layoutWidth, height: clusterH, alignment: .leading)

            VStack(alignment: .leading, spacing: 4) {
                Text("Play a Game with")
                    .font(.system(size: 20, weight: .black))
                    .foregroundStyle(DS.Colors.primaryText)
                Text(character.charName)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundStyle(DS.Colors.secondaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func headerClusterBackgroundDisk(diameter: CGFloat, centerX: CGFloat, centerY: CGFloat) -> some View {
        let diskTint = Color(red: 0.82, green: 0.28, blue: 0.78)
        let r = diameter / 2

        return Circle()
            .fill(
                RadialGradient(
                    gradient: Gradient(stops: [
                        .init(color: diskTint.opacity(0.15), location: 0),
                        .init(color: diskTint.opacity(0.15), location: 0.62),
                        .init(color: diskTint.opacity(0.05), location: 0.86),
                        .init(color: Color.clear, location: 1)
                    ]),
                    center: .center,
                    startRadius: 0,
                    endRadius: r
                )
            )
            .frame(width: diameter, height: diameter)
            .offset(x: centerX - diameter / 2, y: centerY - diameter / 2)
    }

    @ViewBuilder
    private func headerClusterGamestickIcon(iconSize: CGFloat, centerX: CGFloat, centerY: CGFloat) -> some View {
        let pinkCore = Color(red: 0.98, green: 0.32, blue: 0.62)

        if let icon = packageImage(named: "GameControlIcon") {
            icon
                .resizable()
                .renderingMode(.original)
                .scaledToFit()
                .frame(width: iconSize, height: iconSize)
                .shadow(color: pinkCore.opacity(0.38), radius: 5, x: 0, y: 0)
                .offset(x: centerX - iconSize / 2, y: centerY - iconSize / 2)
        }
    }

    @ViewBuilder
    private func avatar(side: CGFloat, cornerRadius: CGFloat) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(Color.white.opacity(0.09))
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
                .frame(width: side, height: side)

            if let bundledMaya = packageImage(named: "MayaCharacter"), !imageFailed {
                bundledMaya
                    .resizable()
                    .scaledToFill()
                    .frame(width: side, height: side)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            } else {
                if let url = URL(string: character.charImage), !imageFailed {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFill()
                        case .failure:
                            initials(side: side)
                                .onAppear { imageFailed = true }
                        case .empty:
                            ProgressView().tint(.white)
                        @unknown default:
                            initials(side: side)
                        }
                    }
                    .frame(width: side, height: side)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                } else {
                    initials(side: side)
                }
            }
        }
        .shadow(color: .black.opacity(0.35), radius: 10, x: 0, y: 6)
    }

    private func initials(side: CGFloat) -> some View {
        let parts = character.charName.split(separator: " ")
        let text = String(parts.prefix(2).map { $0.first.map(String.init) ?? "" }.joined())
        return Text(text.isEmpty ? "AI" : text.uppercased())
            .font(.system(size: max(14, side * 0.32), weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: side, height: side)
    }
}

#Preview {
    MenuHeaderView(character: .init(charID: "1", charName: "Maya", charImage: "https://example.com/maya.png"))
        .padding()
        .background(Color.black)
}
#endif
