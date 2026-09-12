# Verify what ships

Choose checks for the actual change and available environment. Do not report a preview, compiler check or written checklist as completed simulator/device validation.

## Compile and integrate

Confirm the selected files belong to the intended Xcode target, all catalog dependencies are present, and the app has no duplicate theme/component names or additional `@main`. Check the actual scheme, deployment target and Swift mode. Use the repository's normal build command or `xcodebuild` with its real project/workspace, scheme and available simulator destination. Do not change signing settings or deployment support just to make sample code build.

For skill-source maintenance on a Mac with Xcode, a compiler check can type-check the bundled files against the installed iPhone Simulator SDK:

```sh
xcrun swiftc -typecheck -swift-version 6 -target arm64-apple-ios17.0-simulator -sdk "$(xcrun --sdk iphonesimulator --show-sdk-path)" -module-cache-path /private/tmp/ios-motion-ui-module-cache assets/swift/*.swift assets/examples/MotionShowcase.swift
```

Adapt the simulator architecture to the machine. This verifies API availability and types against the selected target, not app integration or runtime behavior. If Xcode is unavailable, check catalog/source completeness and report compilation as unverified. Python helpers need only Python 3's standard library; there are no npm or Swift package dependencies.

## Observe the affected UI

Use the app's normal preview/simulator/device tools to exercise the changed flow and its relevant states:

- Light and dark appearance; custom brand foreground/background contrast.
- A compact phone, landscape where supported, iPad window adaptation, and long/localized content.
- Default text size and an accessibility Dynamic Type size; controls must grow or reflow without losing labels or actions.
- Reduce Motion enabled; verify the result is available with custom spatial effects removed. Check interrupted and repeated interactions.
- VoiceOver labels, traits, reading order, independent child actions, expanded/selected/disabled values, and sensible focus after presentation or errors.
- Loading, empty, error, retry, disabled and success states actually supported by the feature; keyboard entry and dismissal for forms.
- Rapid duplicate activation and navigation away during asynchronous work. Confirm cancellation does not appear as success and persistent work has appropriate ownership.

Use real hardware for haptics and evaluate both enabled/disabled preference behavior when implemented. Simulator success alone cannot establish tactile quality or full performance. Add behavioral automated coverage when the requested change or repository conventions warrant it; avoid tests that merely mirror token values or generated prose.

## Maintain the skill

Validate `SKILL.md` frontmatter with the available skill validator. Ensure local Markdown links, catalog guide/source paths, unique slugs, and dependency closure resolve. Run the installer in an isolated temporary destination to check dry-run, selective dependencies, repeated installs and refusal to overwrite customized files. Keep generated app artifacts and compiler caches out of this skill directory.

When reporting, separate verified compiler/installer behavior from unverified visual, VoiceOver or device behavior. Mention only material remaining work for the delivered change.
