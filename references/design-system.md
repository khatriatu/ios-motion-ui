# One design vocabulary per app

Use this guide when establishing a new interface or changing shared design decisions. The bundled `MotionTheme.swift` and `MotionTokens.swift` are the source of truth for shipped defaults. Inspect them before adapting components; do not maintain a second table of competing numeric values in screen code.

## Establish the profile

Record the chosen preset, accent/foreground pair, text roles, surfaces, spacing/radii, navigation choices, and motion/haptic policy in the app's existing design documentation. [The profile asset](../assets/app-style.md) supplies a starting contract. Link to actual Swift declarations rather than duplicating every value. Reuse the profile in later sessions so successive screens do not invent a new aesthetic.

| Preset | Use | Character |
| --- | --- | --- |
| native | Default for a new app without a specific brief | Clear system surfaces, restrained springs, continuous corners |
| calm | Reading, focused tools, frequent interactions | Quieter geometry and motion; little overshoot |
| expressive | A brief calling for a playful product | Softer shapes and livelier small interactions; task completion stays immediate |

These are app-wide choices, not presets to mix per component. None bypass accessibility preferences. They translate the upstream idea of shared style presets into native choices; they do not imitate its six web themes. An existing brand may override the preset while retaining shared component behavior.

Apply `.motionTheme(theme)` above the relevant hierarchy. Configure the app's `AccentColor` asset or the theme's accent, and verify its pairing with `onAccent`. A bright brand color may require dark foreground text; `.white` is not automatically legible. Let system controls inherit the same tint. Explicit presentation/window roots should receive the same app configuration when inheritance is not sufficient.

## Tokens and composition

- Colors represent roles: content/background/surface, primary/secondary text, accent/on-accent, border, and semantic status. Brand asset colors need appearance variants where necessary. Use status text and SF Symbols alongside color.
- Use native Dynamic Type styles for title, heading, body, and supporting text. Scale custom fonts with `relativeTo:`. Reserve monospaced digits for changing numbers; do not make all content monospaced.
- Share a small spacing scale and continuous corner styles. Use minimum control heights with vertical padding, not fixed text heights. Native list/form insets remain native unless the product needs a deliberate shared adjustment.
- Use native `List` and `Form` for their semantics, editing and settings behavior. Use `ScrollView`/lazy stacks for custom composed surfaces. A card should express a real content grouping; avoid putting every line in a separate card.
- Keep a consistent action hierarchy: one emphasized primary action per local task, secondary actions visually quieter, destructive actions explicit. Prefer native toolbar controls in system chrome and the bundled styles within custom content.
- Keep icon weights and sizes consistent with adjacent text. Decorative symbols are hidden from VoiceOver; icon-only buttons need labels. Avoid fixed dimensions that clip localized text.

## Extend without drift

First search for an existing component with the same behavior. Extend its meaningful variants instead of copying it to add a color or radius override. Keep unusual one-off artwork local; do not turn every constant into a token. Only promote a repeated app-level decision into the theme.

When integrating into an existing token system, map these roles into that system and replace the template references. Do not install another theme solely to satisfy these sample names. Preserve state stores, routing and dependencies already in use. The goal is consistent behavior and design decisions, not identical filenames in every project.

For a requested redesign, choose one representative screen to establish the revised theme, then apply that same decision to other in-scope screens. Record app-local exceptions with their reason so later work can distinguish intentional variation from drift.
