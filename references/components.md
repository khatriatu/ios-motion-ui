# Bundled SwiftUI components

The sources are designed to be copied into an app target, inspected and adapted. They are not a prebuilt Swift package and contain no app entry point. All use the iOS 17 baseline. Read the selected source for its full contract; the catalog and installer resolve shared dependencies.

| Catalog slug | Source / type | Contract |
| --- | --- | --- |
| foundation | `MotionTheme.swift`, `MotionTokens.swift` | App-level style environment and named motion roles |
| button-style | `MotionButtonStyle.swift` / `MotionButtonStyle` | Primary, secondary, destructive styles for actual `Button` controls |
| card | `MotionCard.swift` / `MotionCard` | Shared grouped surface with view-builder content; no hidden tap action |
| chip | `MotionChip.swift` / `MotionChip` | Boolean selection binding, readable label and selected state |
| disclosure | `MotionDisclosure.swift` / `MotionDisclosure` | Native disclosure semantics with caller-owned expansion state |
| status-label | `MotionStatusLabel.swift` / `MotionStatusLabel` | Info, success, warning, error or loading with visible localized text |
| async-button | `MotionAsyncButton.swift` / `MotionAsyncButton` | View-scoped async throwing action, duplicate suppression and required error callback |

## Shared configuration

```swift
let theme = MotionTheme(
    preset: .native,
    accent: .accentColor,
    onAccent: .white,
    hapticsEnabled: false
)

// Apply to the app's existing root view, without adding a new app entry point.
RootView()
    .motionTheme(theme)
```

`RootView` stands for the existing app root. Keep one theme configuration in the app, and use the same configuration for additional scenes. Validate the `accent`/`onAccent` contrast pair for the actual brand in both appearances. The preset choices are `.native`, `.calm`, and `.expressive`. `MotionTheme(reduceMotion: true)` supplies an optional app preference for reduced custom motion; the system setting always takes precedence. The gallery uses this preference to preview the fallback because SwiftUI's system Reduce Motion environment value is read-only.

Native controls inherit the theme's tint. Use ordinary native button styles where system chrome already supplies the right appearance. Apply `MotionButtonStyle` inside custom content where the shared brand styling is wanted:

```swift
Button("Continue", action: continueFlow)
    .buttonStyle(MotionButtonStyle(.primary))

Button("Remove", role: .destructive, action: removeItem)
    .buttonStyle(MotionButtonStyle(.destructive))
```

The action functions above are app-owned. The `.destructive` appearance does not confer destructive semantics on a normal button; retain `role: .destructive` when appropriate. Icons and labels stay at the call site, enabling localization and accessibility names. `expandsHorizontally:` controls whether the style fills the available width.

## Composition and state

```swift
@State private var favoritesOnly = false
@State private var detailsExpanded = false

// Inside a view's body:
MotionCard {
    VStack(alignment: .leading) {
        MotionChip("Favorites", isSelected: $favoritesOnly)
        MotionDisclosure("Details", isExpanded: $detailsExpanded) {
            Text("Additional information for this item.")
        }
        MotionStatusLabel("Saved", status: .success)
    }
}
```

Chip and disclosure state belongs to the caller, so changing screens, selections and data can use the app's existing ownership model. A status label communicates state; it does not launch work or auto-dismiss an error. Preserve all independently actionable children when grouping accessibility elements. A card has no action by default; compose explicit buttons rather than nesting multiple controls inside another button.

For a short, cancellable, view-scoped action:

```swift
MotionAsyncButton(
    "Save",
    loadingTitle: "Saving…",
    action: { try await saveDraft() },
    onError: { error in presentSaveError(error) }
)
```

`saveDraft` and `presentSaveError` are app implementations, not services provided by the skill. The action runs in a main-actor task; await asynchronous I/O and keep heavy synchronous computation off the UI actor. The caller must present a useful recoverable error through `onError`; logging alone is not user feedback. The control owns transient execution, disables duplicate submissions, and cancels on disappearance. Its success feedback occurs only when the action finishes without failure or cancellation.

Use a regular button bound to service-owned state instead when an operation must outlive the view. A cooperative cancellation request does not roll back backend side effects. Do not use the sample button as an implicit architecture for payments or long background uploads.

## Native recipes

Catalog entries marked `native` point to [native-patterns.md](native-patterns.md). They describe use of existing SwiftUI APIs and have no custom source to copy. The installer explains this rather than generating placeholder wrappers. Adapt those patterns to the actual flow, deployment target and container.

## Gallery and target membership

```sh
python3 scripts/components.py install foundation --destination /path/to/App/DesignSystem --include-preview --dry-run
```

The preview flag includes every bundled component and `MotionShowcase.swift`. After copying, add the files to the intended target if its source membership is not automatic. Open the showcase in Xcode previews to inspect the components together. Its local sample actions are demonstrations; replace them with real product behavior in production screens. The source has no `@main`, signing requirements or external services.

For normal feature work omit the gallery and copy only the selected components. Existing customized files require manual integration; the installer deliberately offers no overwrite flag. It leaves an attribution notice and a manifest of copied source hashes beside the files. Keep attribution when redistributing adapted source, and preserve app edits during upgrades.
