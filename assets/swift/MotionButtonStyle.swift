import SwiftUI

/// Apply to native Button. Use `Button(role: .destructive)` for destructive actions.
struct MotionButtonStyle: ButtonStyle {
    enum Variant: Sendable {
        case primary, secondary, destructive
    }

    var variant: Variant
    var expandsHorizontally: Bool

    @Environment(\.motionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
    @Environment(\.colorSchemeContrast) private var contrast
    @Environment(\.isEnabled) private var isEnabled

    private var reduceMotion: Bool { systemReduceMotion || theme.reduceMotion }

    init(_ variant: Variant = .primary, expandsHorizontally: Bool = false) {
        self.variant = variant
        self.expandsHorizontally = expandsHorizontally
    }

    func makeBody(configuration: Configuration) -> some View {
        let effectiveVariant: Variant = configuration.role == .destructive ? .destructive : variant
        let isPressed = configuration.isPressed && isEnabled
        let shape = RoundedRectangle(cornerRadius: theme.radii.control, style: .continuous)

        ZStack {
            configuration.label
                .font(theme.typography.control)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, theme.spacing.standard)
                .padding(.vertical, theme.spacing.medium)
                .frame(
                    minWidth: MotionTheme.Layout.minimumControlTarget,
                    maxWidth: expandsHorizontally ? .infinity : nil,
                    minHeight: MotionTheme.Layout.minimumControlTarget
                )
                .foregroundStyle(foreground(for: effectiveVariant))
                .background(background(for: effectiveVariant), in: shape)
                .overlay {
                    shape.strokeBorder(
                        border(for: effectiveVariant),
                        lineWidth: contrast == .increased ? 2 : 1
                    )
                }
                .opacity(isEnabled ? (isPressed ? 0.86 : 1) : 0.5)
                .scaleEffect(isPressed ? MotionTokens.pressedScale(preset: theme.preset, reduceMotion: reduceMotion) : 1)
                .animation(MotionTokens.animation(.press, preset: theme.preset, reduceMotion: reduceMotion), value: isPressed)
        }
        // Scale only the visual child; this outer hit region always stays at least 44 × 44.
        .frame(minWidth: MotionTheme.Layout.minimumControlTarget, minHeight: MotionTheme.Layout.minimumControlTarget)
        .contentShape(Rectangle())
        .transaction { if reduceMotion { $0.animation = nil; $0.disablesAnimations = true } }
    }

    private func foreground(for variant: Variant) -> Color {
        variant == .primary ? theme.onAccent : theme.colors.text
    }

    private func background(for variant: Variant) -> Color {
        variant == .primary ? theme.accent : theme.colors.surface
    }

    private func border(for variant: Variant) -> Color {
        switch variant {
        case .primary: return contrast == .increased ? theme.onAccent : .clear
        case .secondary: return contrast == .increased ? theme.colors.text : theme.colors.border
        case .destructive: return theme.colors.error
        }
    }
}
