import SwiftUI

/// Preserve the system disclosure's expansion semantics and keyboard/VoiceOver support.
struct MotionDisclosure<Content: View>: View {
    private let title: LocalizedStringKey
    @Binding private var isExpanded: Bool
    private let content: Content
    @Environment(\.motionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion

    private var reduceMotion: Bool { systemReduceMotion || theme.reduceMotion }

    init(
        _ title: LocalizedStringKey,
        isExpanded: Binding<Bool>,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self._isExpanded = isExpanded
        self.content = content()
    }

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            content
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, theme.spacing.small)
        } label: {
            Text(title)
                .font(theme.typography.control)
                .foregroundStyle(theme.colors.text)
                .fixedSize(horizontal: false, vertical: true)
                .frame(minHeight: MotionTheme.Layout.minimumControlTarget, alignment: .leading)
        }
        .tint(theme.accent)
        .animation(MotionTokens.animation(.gentle, preset: theme.preset, reduceMotion: reduceMotion), value: isExpanded)
        .transaction { if reduceMotion { $0.animation = nil; $0.disablesAnimations = true } }
    }
}
