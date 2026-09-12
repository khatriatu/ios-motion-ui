import SwiftUI

/// Pair a visible status message with a distinct symbol; color is supplementary.
struct MotionStatusLabel: View {
    enum Status: Sendable {
        case info, success, warning, error, loading

        var symbol: String {
            switch self {
            case .info: return "info.circle.fill"
            case .success: return "checkmark.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .error: return "xmark.octagon.fill"
            case .loading: return "hourglass"
            }
        }
    }

    private let title: LocalizedStringKey
    private let status: Status
    @Environment(\.motionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion

    private var reduceMotion: Bool { systemReduceMotion || theme.reduceMotion }

    init(_ title: LocalizedStringKey, status: Status) {
        self.title = title
        self.status = status
    }

    var body: some View {
        HStack(alignment: .center, spacing: theme.spacing.small) {
            Group {
                if status == .loading && !reduceMotion {
                    ProgressView().controlSize(.small).tint(symbolColor)
                } else {
                    Image(systemName: status.symbol).foregroundStyle(symbolColor)
                }
            }
            .accessibilityHidden(true)

            Text(title)
                .foregroundStyle(theme.colors.text)
                .fixedSize(horizontal: false, vertical: true)
        }
        .font(theme.typography.supporting)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(title))
        .transaction { $0.animation = nil }
    }

    private var symbolColor: Color {
        switch status {
        case .info, .loading: return theme.accent
        case .success: return theme.colors.success
        case .warning: return theme.colors.warning
        case .error: return theme.colors.error
        }
    }
}
