import SwiftUI

/// A toggleable filter; the containing screen owns selection and persistence.
struct MotionChip: View {
    private let title: LocalizedStringKey
    @Binding private var isSelected: Bool
    @Environment(\.motionTheme) private var theme

    init(_ title: LocalizedStringKey, isSelected: Binding<Bool>) {
        self.title = title
        self._isSelected = isSelected
    }

    var body: some View {
        Button {
            isSelected.toggle()
        } label: {
            HStack(spacing: theme.spacing.small) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .accessibilityHidden(true)
                Text(title)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .buttonStyle(MotionButtonStyle(isSelected ? .primary : .secondary))
        .accessibilityLabel(Text(title))
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}
