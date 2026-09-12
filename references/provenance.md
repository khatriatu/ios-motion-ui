# Source and adaptation record

This standalone **ios-motion-ui 1.0.0** skill was built with reference to [Rkj0123/motion-ui-skill](https://github.com/Rkj0123/motion-ui-skill), reviewed at commit **c47f716a2c120d4a9bc1a79ecc2102c4b4ec227c** on **2026-09-12**. It does not depend on that repository at runtime and does not require another local iOS skill.

Source material inspected included `SKILL.md`, `catalog.json`, `lib/ease.ts`, the component-copy installer, style/design-system guidance, motion-engineering guidance, and mobile interaction guidance. The upstream repository describes 130 React/Next.js components. This adaptation provides a focused set of native SwiftUI components plus documented native API alternatives, not all 130 implementations.

## Retained ideas

- An offline component catalog with explicit source, dependencies and documentation.
- Reusable source copied selectively into an app, rather than a required runtime framework.
- Shared semantic design and motion tokens, with an app-level visual preset.
- Motion tied to interaction purpose, accessible reduced-motion alternatives, stable readable state changes and semantic haptics.

## Native adaptations

- React components and hooks become SwiftUI views, styles, bindings and environment values. No TypeScript, Tailwind, Motion, DOM or npm dependency is included.
- Web spring configuration becomes SwiftUI motion roles with native tuning, not mechanically translated coefficients.
- Native navigation, sheets, selection, text input, accessibility and scrolling replace browser-specific interaction infrastructure.
- The upstream six web aesthetics become three shared native presets. Essential task behavior and accessibility stay consistent across presets.
- Copying is selective and refuses to overwrite differing files. The manifest records the adaptation version and copied file hashes for later manual migration.

Bundled Swift code is a new native implementation informed by those ideas. The upstream MIT copyright and permission notice is retained in the skill's `LICENSE` and copied as `IOSMotionUI-LICENSE.txt` with component installations. Preserve that notice with redistributed adaptations. This provenance document may be copied as `IOSMotionUI-PROVENANCE.md` beside installed components.

## Primary platform references

- [SwiftUI spring animation](https://developer.apple.com/documentation/swiftui/animation/spring%28duration%3Abounce%3Ablendduration%3A%29)
- [Reduce Motion environment](https://developer.apple.com/documentation/swiftui/environmentvalues/accessibilityreducemotion)
- [SwiftUI modal presentations](https://developer.apple.com/documentation/swiftui/modal-presentations)
- [Sensory feedback](https://developer.apple.com/documentation/swiftui/sensoryfeedback)
- [Numeric content transitions](https://developer.apple.com/documentation/swiftui/contenttransition/numerictext(value:))

The reviewed source revision is pinned for traceability. Recheck availability in the consuming app's SDK when using platform APIs beyond the bundled baseline.
