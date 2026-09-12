# Translate the interaction, then choose the native primitive

Use this mapping when selecting a component from the upstream Motion UI vocabulary. Rows below are implementation recipes, not claims that separate Swift components are bundled. The machine-readable catalog marks them `native`.

| Upstream interaction | Native iOS choice | Integration decision |
| --- | --- | --- |
| Button / haptic pressable | `Button` + `ButtonStyle` | Preserve activation, roles, disabled state, and keyboard/VoiceOver behavior |
| Stateful / action-swap button | Bundled `MotionAsyncButton` | Keep label space readable; cancel transient work without fake completion |
| Bottom sheet / drawer / morphing modal | `.sheet`, `.presentationDetents` | Let iOS manage drag, dismissal, focus and compact-height adaptation |
| Center modal / action sheet | `.sheet`, `.confirmationDialog`, `.alert` | Pick task presentation vs a short choice vs an interrupting message |
| Popover / hover card | `.popover`, `Menu`, explicit information button | Support tap; allow compact-width adaptation instead of relying on hover |
| Tabs / dock / sidebar | `TabView`, `NavigationSplitView` | Tabs represent peer destinations; sidebar reflects the app hierarchy |
| Page transition / breadcrumb | `NavigationStack`, `NavigationLink` | Preserve back gesture, title hierarchy and restoration model |
| Segmented control / radio group | `Picker` with `.segmented` or an appropriate style | Use short choices; fall back to a menu/list for longer localized labels |
| Toggle / checkbox | `Toggle` or native multi-selection list | Do not replace a switch with a decorative shape and tap gesture |
| Input / password input | `TextField`, `SecureField`, `@FocusState` | Configure content types, keyboard, submit actions, autofill and local errors |
| Select / combobox / autocomplete | `Picker`, `Menu`, `.searchable` with results | Keep query, focus and selection separate; no desktop listbox emulation |
| Multi-select / chips | Selection list + bundled `MotionChip` | Make selected state and removal actions accessible |
| Accordion / collapsible | `DisclosureGroup` or bundled `MotionDisclosure` | Preserve expanded/collapsed semantics and flexible content height |
| Number field / adaptive stepper | `Stepper`, `Slider` | Use native min/max, increments and accessibility adjustment |
| Number animation / metric | `Text` + `.contentTransition(.numericText(value:))` | Localize formatting; retain actual value; disable motion when requested |
| Loader / progress ring | `ProgressView` | Determinate only when real progress is known; include a readable phase |
| Badge / success check | Bundled `MotionStatusLabel` | Pair semantic icon with text; success follows an actual operation |
| Pull to refresh | `.refreshable` | Await the refresh task; report recovery if it fails |
| Sortable list / swipe actions | `List`, `.onMove`, `.swipeActions` | Preserve edit semantics; keep a visible alternative for essential actions |
| Carousel | Horizontal `ScrollView` and supported scroll target APIs, or page-style `TabView` | No automatic scrolling of essential content; retain native scrolling |
| Date range / calendar | `DatePicker`, `MultiDatePicker` when appropriate | `MultiDatePicker` is a set of dates, not a continuous range; validate range endpoints explicitly |
| Color picker | `ColorPicker` | Use the system picker and accessibility behavior |
| Copy / share | `UIPasteboard` for explicit copy, `ShareLink` for sharing | Trigger from the user's action; visibly confirm meaningful outcomes |
| Toast / error shake | Inline status or transient banner; alert for blocking issues | Keep actionable errors present until resolved; avoid shaking as the only cue |
| File tree / cascader | `OutlineGroup`, hierarchical lists and navigation | Preserve depth and selection semantics on small screens |
| Chat / AI surfaces | Lazy message list, multiline input, explicit task state | Do not scroll away from reading, announce every token, or imply a preview is an executed action |
| Kanban / timeline / scheduler | App-specific composition with native lists, grids, date and drag APIs | Model the domain first; do not copy web dashboard density to a narrow phone |
| Dynamic Island | ActivityKit + WidgetKit when the task warrants a Live Activity | A floating in-app pill is not the system Dynamic Island; extensions and capabilities are separate work |
| Magnetic cursor / spotlight / tilt | Optional pointer enhancement on supported devices | Omit from ordinary touch interactions; essential information must stay discoverable |

## Platform boundaries

The bundled components use iOS 17 as their supported source baseline, not as a reason to change an existing app's deployment target. For older targets, adapt the selected implementation, use an available equivalent, or gate newer calls with a functional fallback. `NavigationStack` and sheet detents are iOS 16-era APIs; `sensoryFeedback`, numeric content transitions, and advanced scroll behaviors require checking their particular overload and target support.

Use the installed SDK and Apple's API declarations to verify newer effects before using them. Prefer native controls so their platform appearance can evolve. An iOS appearance preset from a React library is not authority for current system chrome. Do not impose decorative glass, floating tab bars, fake safe areas, or fixed phone frames on an app.

On iPad, respond to the available window and size class instead of device-model checks. Use leading/trailing alignment, preserve keyboard shortcuts where useful, and avoid fixed screen widths from `UIScreen.main.bounds`. Sheets, popovers, navigation and text input should retain system adaptation and dismissal behavior.

Relevant primary references: [SwiftUI modal presentations](https://developer.apple.com/documentation/swiftui/modal-presentations), [presentation detents](https://developer.apple.com/documentation/swiftui/presentationdetent), and [numeric text transitions](https://developer.apple.com/documentation/swiftui/contenttransition/numerictext(value:)).
