import SwiftUI

/// Owns one task until it finishes and requests cancellation when it disappears.
/// The action must cooperate with cancellation and must not block the main actor.
/// Present durable success/error UI in the caller; cancelled work never signals success.
@MainActor
struct MotionAsyncButton: View {
    private let title: LocalizedStringKey
    private let loadingTitle: LocalizedStringKey
    private let variant: MotionButtonStyle.Variant
    private let action: @MainActor () async throws -> Void
    private let onError: @MainActor (Error) -> Void

    @State private var runningTask: Task<Void, Never>?
    @State private var isRunning = false
    @State private var successfulOperations = 0
    @Environment(\.motionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
    @Environment(\.isEnabled) private var isEnabled

    private var reduceMotion: Bool { systemReduceMotion || theme.reduceMotion }

    init(
        _ title: LocalizedStringKey,
        loadingTitle: LocalizedStringKey = "Working…",
        variant: MotionButtonStyle.Variant = .primary,
        action: @escaping @MainActor () async throws -> Void,
        onError: @escaping @MainActor (Error) -> Void
    ) {
        self.title = title
        self.loadingTitle = loadingTitle
        self.variant = variant
        self.action = action
        self.onError = onError
    }

    var body: some View {
        Button(role: variant == .destructive ? .destructive : nil, action: start) {
            // Both labels participate in layout, avoiding a width jump during work.
            ZStack {
                Text(title).opacity(isRunning ? 0 : 1)
                HStack(spacing: theme.spacing.small) {
                    if reduceMotion {
                        Image(systemName: "hourglass")
                    } else if isRunning {
                        ProgressView().tint(variant == .primary ? theme.onAccent : theme.accent)
                    } else {
                        Image(systemName: "hourglass").hidden()
                    }
                    Text(loadingTitle)
                }
                .opacity(isRunning ? 1 : 0)
            }
        }
        .buttonStyle(MotionButtonStyle(variant, expandsHorizontally: true))
        .disabled(isRunning)
        .accessibilityLabel(Text(isRunning ? loadingTitle : title))
        .accessibilityValue(isRunning ? Text("In progress") : Text(""))
        .sensoryFeedback(.success, trigger: successfulOperations) { _, _ in theme.hapticsEnabled }
        .onDisappear { runningTask?.cancel() }
    }

    private func start() {
        guard isEnabled, runningTask == nil else { return }
        isRunning = true
        runningTask = Task { @MainActor in
            defer {
                isRunning = false
                runningTask = nil
            }
            do {
                try Task.checkCancellation()
                try await action()
                try Task.checkCancellation()
                successfulOperations += 1
            } catch is CancellationError {
                // Leaving a screen is not a user-facing failure.
            } catch {
                guard !Task.isCancelled else { return }
                onError(error)
            }
        }
    }
}
