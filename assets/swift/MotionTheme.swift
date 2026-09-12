import SwiftUI

/// Configure once at the app's root; keep the chosen preset in the app's design contract.
/// Validate `accent` and `onAccent` together in light, dark, and Increased Contrast modes.
/// `reduceMotion` supplements the system preference and never disables it.
struct MotionTheme: Sendable {
    enum Preset: String, CaseIterable, Identifiable, Sendable {
        case native, calm, expressive
        var id: String { rawValue }
    }

    var preset: Preset
    var accent: Color
    var onAccent: Color
    var hapticsEnabled: Bool
    /// Optional in-app preference. `false` never overrides the system's Reduce Motion setting.
    var reduceMotion: Bool
    var spacing: Spacing
    private var customRadii: Radii?
    var radii: Radii {
        get { customRadii ?? Radii(preset: preset) }
        set { customRadii = newValue }
    }
    var colors: Colors
    var typography: Typography

    init(
        preset: Preset = .native,
        accent: Color = .accentColor,
        onAccent: Color = .white,
        hapticsEnabled: Bool = false,
        reduceMotion: Bool = false,
        spacing: Spacing = Spacing(),
        radii: Radii? = nil,
        colors: Colors = Colors(),
        typography: Typography = Typography()
    ) {
        self.preset = preset
        self.accent = accent
        self.onAccent = onAccent
        self.hapticsEnabled = hapticsEnabled
        self.reduceMotion = reduceMotion
        self.spacing = spacing
        self.customRadii = radii
        self.colors = colors
        self.typography = typography
    }

    static let native = MotionTheme()
    static let calm = MotionTheme(preset: .calm)
    static let expressive = MotionTheme(preset: .expressive)

    struct Spacing: Sendable {
        var compact: CGFloat = 4
        var small: CGFloat = 8
        var medium: CGFloat = 12
        var standard: CGFloat = 16
        var large: CGFloat = 24
        var section: CGFloat = 32
    }

    struct Radii: Sendable {
        var control: CGFloat = 12
        var card: CGFloat = 20

        init(control: CGFloat = 12, card: CGFloat = 20) {
            self.control = control
            self.card = card
        }

        fileprivate init(preset: Preset) {
            switch preset {
            case .native: self.init(control: 12, card: 20)
            case .calm: self.init(control: 10, card: 16)
            case .expressive: self.init(control: 16, card: 24)
            }
        }
    }

    struct Typography: Sendable {
        var control: Font = .body.weight(.semibold)
        var body: Font = .body
        var supporting: Font = .subheadline
        var sectionTitle: Font = .headline
        var screenTitle: Font = .title2.weight(.semibold)
        var metric: Font = .title3.monospacedDigit()
    }

    enum Layout {
        static let minimumControlTarget: CGFloat = 44
        static let maximumReadableWidth: CGFloat = 640
    }

    struct Colors: Sendable {
        var background = Color(uiColor: .systemGroupedBackground)
        var surface = Color(uiColor: .secondarySystemGroupedBackground)
        var inset = Color(uiColor: .tertiarySystemGroupedBackground)
        var text = Color(uiColor: .label)
        var secondaryText = Color(uiColor: .secondaryLabel)
        var border = Color(uiColor: .separator)
        var success = Color(uiColor: .systemGreen)
        var warning = Color(uiColor: .systemOrange)
        var error = Color(uiColor: .systemRed)
    }
}

private struct MotionThemeKey: EnvironmentKey {
    static let defaultValue = MotionTheme.native
}

extension EnvironmentValues {
    var motionTheme: MotionTheme {
        get { self[MotionThemeKey.self] }
        set { self[MotionThemeKey.self] = newValue }
    }
}

extension View {
    func motionTheme(_ theme: MotionTheme) -> some View {
        environment(\.motionTheme, theme).tint(theme.accent)
    }
}
