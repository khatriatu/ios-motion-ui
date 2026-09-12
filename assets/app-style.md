# App interface profile

Starting profile from ios-motion-ui 1.0.0. Copy into the app's existing documentation only when no equivalent profile exists. Replace these defaults with actual app decisions and link to their Swift declarations as the interface is implemented.

- **Baseline:** ios-motion-ui 1.0.0. App source copies are versioned with the app and do not auto-update.
- **Preset:** native. Keep one preset across the app; change it centrally when the brief calls for calm or expressive.
- **Theme owner:** a single app-level configuration of MotionTheme, or the app's existing equivalent. Record its source path here once integrated.
- **Brand:** AccentColor from the app asset catalog. Match on-accent text to the chosen accent and verify light/dark contrast before release.
- **Typography:** system Dynamic Type title, headline, body and caption roles. SF Symbols match adjacent text. Changing metrics use monospaced digits.
- **Layout:** shared theme spacing and radii; native safe areas; flexible text height; minimum 44-by-44-point controls. Adapt layouts to iPad window size and accessibility text sizes.
- **Surfaces:** semantic system background and grouped surfaces. Cards indicate real groupings. System navigation and presentations retain their native appearance.
- **Actions:** emphasized primary, quieter secondary, explicit destructive role. Loading prevents accidental repeat submissions and includes understandable text.
- **Navigation:** use native navigation stacks, tabs for peer destinations, and sheets for modal tasks as required by the app. Document the chosen destinations here rather than inheriting sample tabs.
- **Motion:** shared semantic motion roles; Reduce Motion removes custom spatial motion. No animation delays before actions, navigation, or completion.
- **Haptics:** disabled in the baseline. If the product enables them, use semantic outcomes and respect the app preference; visible state remains sufficient.
- **Copy and state:** localizable concise action labels; useful empty/loading/error/success content tied to the actual feature. Errors explain recovery without exposing implementation details.
- **Intentional exceptions:** none initially. Record the component/screen, reason and scope when an exception is introduced.

During a consistency review, compare actual screens with this profile and the linked source. Update the profile when app-wide decisions change so it remains descriptive of the shipped interface.
