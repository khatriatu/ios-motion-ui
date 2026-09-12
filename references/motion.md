# Motion is shared interaction behavior

Choose motion to explain what changed: a control was pressed, content was replaced, selection moved, a group expanded, or a task finished. Frequent actions should feel immediate. Read the bundled `MotionTokens.swift` for canonical native tuning; keep changes there so components retain the same character.

## Semantic roles

| Role | Purpose | Boundaries |
| --- | --- | --- |
| press | Immediate tactile feedback | Small compression; keep the hit area stable and action immediate |
| swap | Label, icon, or short state replacement | Keep baseline and available space stable; do not obscure essential status |
| layout | Local selection or expansion | Scope to the changing value; avoid moving the entire screen |
| panel | A custom in-app panel | Let system sheets manage their own animation; do not animate them twice |
| gentle | A spacious, occasional local expansion | No decorative travel while reading or scrolling |
| celebration | A small meaningful success accent | Only after confirmed success and sparingly; never block the next action |

The upstream library uses mass/stiffness/damping objects. These SwiftUI roles use native spring APIs and native tuning; their values are not a numeric conversion or a claim of identical physics. Native `spring` supports continuity when interrupted by compatible springs. Validate the result under rapid repeated interaction, not only on a single slow tap. [Apple's spring reference](https://developer.apple.com/documentation/swiftui/animation/spring%28duration%3Abounce%3Ablendduration%3A%29) documents that behavior.

## Implement custom changes

Read `@Environment(\.accessibilityReduceMotion)` in the view initiating motion. With the bundled theme, combine it with the optional app preference: `let reduceMotion = systemReduceMotion || theme.reduceMotion`. The app preference can reduce custom motion further; it cannot override the system setting or change native system animations. Use `MotionTokens.animation(role, preset: theme.preset, reduceMotion: reduceMotion)` with a scoped `withAnimation` or `.animation(_:value:)`.

For Reduce Motion, remove scale, translation, rotation, parallax, bounce, and animated shared geometry. The bundled helper returns no animation. A brief opacity-only transition can be appropriate for another component, but it must not carry a hidden spatial effect. Disable inherited animation in a local transaction where necessary so a parent cannot animate an intended static fallback. React's `useReducedMotion` maps to this environment behavior, not to shortening all durations. See [Apple's Reduce Motion environment value](https://developer.apple.com/documentation/swiftui/environmentvalues/accessibilityreducemotion).

Use `.transition` for conditional insertion/removal. Keep stable data identities so state survives updates. Use `matchedGeometryEffect` only for a shared object inside a suitable common hierarchy; it is not an automatic cross-sheet/navigation transition. Do not animate `UUID()` identity churn, the initial appearance of every recycled list row, or every streamed text token.

Custom numeric transitions should switch to `.identity` under Reduce Motion and use the same value for display formatting and transition direction. Use `monospacedDigit()` when it improves stability, without fixing a width that truncates larger values.

Prefer native scrolling, sheets, sliders, toggles and navigation for their gesture handoffs. Do not import browser practices such as `AnimatePresence` wait queues, FLIP measurements, DOM listeners or global animation overrides into SwiftUI. Layout animation in SwiftUI has different tradeoffs; measure actual expensive layouts before adding workarounds.

## Haptics and operation state

The baseline theme disables custom haptics. If enabled for the app, use semantic feedback for a meaningful selection, threshold or actual result. The native `sensoryFeedback` API is available in the bundled iOS 17 baseline; see [Apple's feedback reference](https://developer.apple.com/documentation/swiftui/sensoryfeedback).

Trigger feedback from a changing event/state value, not `onAppear`. A tap means intent, not success. Cancellation, duplicate taps, a failed request, or view reappearance must not produce a success event. Native controls may already supply feedback; avoid duplicating it. Reduce Motion and haptic preference are separate inputs; do not infer one from the other. Visible and accessible state must work without haptics.

Operation ownership matters: short view-scoped work may cancel when the view disappears. A download, payment, upload or other operation that should outlive the view belongs in the app's service/state layer. Bind controls to its status rather than launching a second task from each appearance. Cancellation is cooperative; UI code cannot promise to undo work already committed by a service.

## Performance and readability

Keep animation near the changed view and avoid repeated blur, shadow, geometry measurement and idle loops. Use lazy collections for large content. Do not add offscreen rendering or `drawingGroup()` by default. Stop optional repeating effects when inactive/offscreen, and retain a static alternative.

Ensure the final state appears immediately when motion is disabled or interrupted. For progress, show real completion or an honest indeterminate state; never animate a percentage to imply measured work when none exists.
