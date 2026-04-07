import SwiftUI

#if os(iOS)
enum DS {
    enum Colors {
        static let background = Color(red: 0.043, green: 0.043, blue: 0.059)
        static let surface = Color.white.opacity(0.06)
        static let border = Color(red: 120 / 255, green: 200 / 255, blue: 255 / 255).opacity(0.12)
        static let primaryText = Color.white
        static let secondaryText = Color.white.opacity(0.75)
        static let overlay = Color.black.opacity(0.84)
        static let accent = Color(red: 59 / 255, green: 130 / 255, blue: 246 / 255)
        static let modalBackgroundTop = Color(red: 0.20, green: 0.22, blue: 0.30).opacity(0.72)
        static let modalBackgroundBottom = Color(red: 0.12, green: 0.14, blue: 0.22).opacity(0.78)
        /// Solid modal shell tuned to a neutral charcoal-gray (reference is less blue).
        static let modalCardFillTop = Color(red: 0.208, green: 0.224, blue: 0.282)
        static let modalCardFillBottom = Color(red: 0.148, green: 0.164, blue: 0.224)
        /// Subtle bottom lift with low chroma so card reads gray instead of blue.
        static let modalCardAura = Color(red: 0.170, green: 0.205, blue: 0.245)
        static let modalCardBorder = Color(red: 0.28, green: 0.30, blue: 0.36)
        static let scrim = Color.black.opacity(0.48)
    }

    enum Spacing {
        static let xSmall: CGFloat = 8
        static let small: CGFloat = 12
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
    }

    enum CornerRadius {
        static let modal: CGFloat = 24
        static let card: CGFloat = 18
    }
}
#endif
