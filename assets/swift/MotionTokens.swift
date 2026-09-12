import SwiftUI

/// Native timing choices grouped by intent; these are not web spring conversions.
enum MotionTokens {
    enum Role: Sendable {
        case press, swap, layout, panel, gentle, celebration
    }

    /// `nil` means an immediate update. Also remove spatial effects when Reduce Motion is on.
    static func animation(
        _ role: Role,
        preset: MotionTheme.Preset = .native,
        reduceMotion: Bool
    ) -> Animation? {
        guard !reduceMotion else { return nil }

        let duration: TimeInterval
        switch role {
        case .press: duration = 0.18
        case .swap: duration = 0.22
        case .layout: duration = 0.30
        case .panel: duration = 0.36
        case .gentle: duration = 0.42
        case .celebration: duration = 0.40
        }

        switch preset {
        case .calm:
            return .easeInOut(duration: duration * 0.85)
        case .native:
            return .spring(duration: duration, bounce: role == .celebration ? 0.16 : 0)
        case .expressive:
            // Layout and panels remain controlled so text and controls do not overshoot.
            let bounce: Double = switch role {
            case .press: 0.08
            case .celebration: 0.24
            default: 0
            }
            return .spring(duration: duration, bounce: bounce)
        }
    }

    static func pressedScale(preset: MotionTheme.Preset, reduceMotion: Bool) -> CGFloat {
        guard !reduceMotion else { return 1 }
        switch preset {
        case .calm: return 0.99
        case .native: return 0.98
        case .expressive: return 0.96
        }
    }
}
