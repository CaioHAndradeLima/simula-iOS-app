import SwiftUI

#if os(iOS)
extension View {
    @ViewBuilder
    func applyCarouselTargetLayout() -> some View {
        if #available(iOS 17.0, *) {
            self.scrollTargetLayout()
        } else {
            self
        }
    }

    @ViewBuilder
    func applyNaturalCarouselPaging() -> some View {
        if #available(iOS 18.0, *) {
            self
                .scrollTargetBehavior(.viewAligned(limitBehavior: .alwaysByFew))
        } else {
            self
        }
    }
}

func packageImage(named name: String) -> Image? {
    #if SWIFT_PACKAGE
    return Image(name, bundle: .module)
    #else
    return nil
    #endif
}
#endif
