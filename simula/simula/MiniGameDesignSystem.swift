import SwiftUI

enum MiniGameDS {
    enum Colors {
        static let background = Color(red: 0.043, green: 0.043, blue: 0.059)
        static let surface = Color.white.opacity(0.06)
        static let border = Color(red: 120 / 255, green: 200 / 255, blue: 255 / 255).opacity(0.10)
        static let textPrimary = Color.white
        static let textSecondary = Color.white.opacity(0.75)
        static let overlayGradientTop = Color.black.opacity(0.0)
        static let overlayGradientBottom = Color.black.opacity(0.95)
        static let accent = Color(red: 59 / 255, green: 130 / 255, blue: 246 / 255)
    }

    enum Spacing {
        static let xSmall: CGFloat = 8
        static let small: CGFloat = 12
        static let medium: CGFloat = 16
        static let large: CGFloat = 20
        static let xLarge: CGFloat = 24
    }

    enum Radius {
        static let card: CGFloat = 18
        static let modal: CGFloat = 24
        static let avatar: CGFloat = 16
    }
}
