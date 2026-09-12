---
name: ios-motion-ui
description: Build and refine consistent native iOS interfaces with SwiftUI design tokens, reusable components, purposeful motion, and accessible interaction patterns. Use for iPhone or iPad screens, app design systems, UI components, animation polish, and visual consistency reviews. Not for React Native, web UI, or backend-only work.
---

# iOS Motion UI

Create a recognizable family of native iOS apps. Reuse a common visual and interaction vocabulary while allowing each app its own brand and content. This skill adapts the catalog, shared-token, and source-copy workflow of [Motion UI](https://github.com/Rkj0123/motion-ui-skill) to SwiftUI; it is self-contained and requires no other skill.

Version **1.0.0**. Bundled Swift sources target **iOS 17+**, use SwiftUI and system frameworks, and require no external packages. This is a focused native adaptation, not a port of all 130 web components. The catalog distinguishes working bundled sources from native API recipes.

## Start with the app

1. Inspect repository instructions, Xcode targets, deployment target, Swift version, existing design tokens, component library, navigation, and state ownership. Scope changes to the requested feature. Preserve the architecture and minimum OS; do not replace an app shell to add a component.
2. Find the app's design profile or equivalent documented conventions. For a new design system, use [design-system.md](references/design-system.md) and adapt [app-style.md](assets/app-style.md) into the app's existing documentation location. Start with the native preset unless the brief or existing product implies another. State assumptions and proceed; ask only for decisions that block the requested work.
3. Reuse existing equivalents first. Otherwise search [catalog.json](catalog.json), read the selected source and its guide, and copy only the necessary components and their dependencies. Use native controls for standard platform behavior; consult [native-patterns.md](references/native-patterns.md).
4. Apply one app-level theme to the common root. Route repeated color, typography, spacing, radius, and animation decisions through shared tokens. Introduce a new component or token only when a repeated design decision justifies it. Keep product copy and business state at the call site.
5. Implement the actual flow, including relevant loading, empty, error, disabled, and success states. Use [motion.md](references/motion.md) for custom motion and haptics, and [components.md](references/components.md) for bundled component contracts.
6. Verify the affected interface using [verification.md](references/verification.md). Report files changed, shared decisions established, checks actually completed, and concrete remaining integration work. A compiler check is not a visual or device accessibility check.

## Choose the relevant path

- **New screens or an app UI:** establish the shared style, use native navigation, then compose feature-specific content. Add onboarding, settings, authentication, or subscriptions only if required by the product brief.
- **An existing screen or component:** follow its established design system, adapt source names and tokens if needed, and avoid adding a parallel theme implementation.
- **Motion polish:** identify the state change and its purpose before choosing a motion role. Read [motion.md](references/motion.md); preserve task speed and native gestures.
- **Consistency review:** compare the requested screens with the app profile and shared components. Identify concrete deviations with locations. If asked to fix them, edit shared causes before individual screens; do not redesign unrelated flows.

## Find and copy components

Run these commands from this skill directory; use absolute script paths when working inside an app:

```sh
python3 scripts/components.py list
python3 scripts/components.py list --search button
python3 scripts/components.py info async-button
python3 scripts/components.py install button-style card chip --destination /path/to/App/DesignSystem --dry-run
python3 scripts/components.py install button-style card chip --destination /path/to/App/DesignSystem
```

Review the dry-run plan, then execute within the user's authorized workspace. Identical files are reused; differing files cause refusal before copying. Adapt existing files manually when they contain app customizations. The installer records version and source hashes in `.ios-motion-ui.json`; it does not register files in Xcode, create a project, or install the skill globally. Add copied sources to the intended target and check for duplicate type names.

For a component gallery, add `--include-preview`; it includes all bundled components because the gallery uses them. The preview is a SwiftUI view with deterministic sample content, not an app entry point or a production screen. See [components.md](references/components.md) for integration.

## Shared rules

- Prefer `Button`, `Toggle`, `Picker`, `TextField`, `List`, `Form`, `NavigationStack`, and system presentations. Customize the product's surfaces without recreating navigation bars, sheet drag physics, text selection, or the back gesture.
- Use semantic colors with light/dark behavior, scalable text styles, SF Symbols, and leading/trailing alignment. Preserve the platform's safe areas, keyboard behavior, and localization layout.
- Maintain at least 44-by-44-point actionable areas and readable content at accessibility text sizes. Selected, error, and progress states need understandable text or symbols in addition to color. Keep independently actionable children accessible.
- Read Reduce Motion where custom animation starts. Spatial and repeated decorative motion must have a motion-free alternative. Scope animation to the changing state; avoid whole-screen animation modifiers and delays before actions execute.
- Use haptics as optional semantic feedback for actual outcomes. Do not infer success from a tap, replay feedback on appearance, or require vibration to understand state.
- Keep data and task ownership explicit. Canceled operations must not report success; persistent work belongs outside a transient button or view. Example data and services must be identified as examples.

## Consistency across apps and revisions

Use the same baseline tokens and component contracts for new apps. Brand changes belong in one app-level theme/profile, not scattered screen overrides. Preserve an existing app's conventions unless the user requests a migration. A screen-specific exception stays local and documented; changing the reusable standard requires an explicit shared-standard request.

App copies do not auto-update. Review version changes and app customizations before migrating; never recopy over a modified theme. When maintaining this skill, update the catalog version for a release, preserve the upstream notice, validate catalog paths and dependency selections, and compile affected Swift sources. Read [provenance.md](references/provenance.md) for the reviewed source revision and adaptation decisions.
