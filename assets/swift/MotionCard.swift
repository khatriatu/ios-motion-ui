import SwiftUI

/// A solid semantic surface. No blur or transparency is needed for this baseline.
struct MotionCard<Content: View>: View {
    @Environment(\.motionTheme) private var theme
    @Environment(\.colorSchemeContrast) private var contrast
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(theme.spacing.standard)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(theme.colors.surface, in: RoundedRectangle(cornerRadius: theme.radii.card, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: theme.radii.card, style: .continuous)
                    .strokeBorder(contrast == .increased ? theme.colors.text : theme.colors.border, lineWidth: 1)
                    .allowsHitTesting(false)
            }
    }
}
