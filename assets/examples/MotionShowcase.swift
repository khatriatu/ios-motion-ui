import SwiftUI

/// Local, deterministic interactions. Copy into an app target with assets/swift/*.swift.
struct MotionShowcase: View {
    @Environment(\.motionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
    @State private var showsFavorites = false
    @State private var showsOffline = false
    @State private var detailsExpanded = false
    @State private var count = 0
    @State private var saveStatus: MotionStatusLabel.Status = .info
    @State private var saveMessage: LocalizedStringKey = "Ready to preview the save flow."
    @State private var showsSheet = false

    private var reduceMotion: Bool { systemReduceMotion || theme.reduceMotion }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: theme.spacing.large) {
                    Text("A few familiar actions, one consistent rhythm.")
                        .font(theme.typography.screenTitle)
                        .foregroundStyle(theme.colors.text)

                    MotionCard {
                        VStack(alignment: .leading, spacing: theme.spacing.standard) {
                            Text("Actions").font(theme.typography.sectionTitle)
                            Text("Saved items: \(count)")
                                .font(theme.typography.metric)
                                .contentTransition(reduceMotion ? .identity : .numericText())
                            Button("Add an item", systemImage: "plus") {
                                withAnimation(MotionTokens.animation(.swap, preset: theme.preset, reduceMotion: reduceMotion)) {
                                    count += 1
                                }
                            }
                            .buttonStyle(MotionButtonStyle(.primary, expandsHorizontally: true))

                            Button("View details", systemImage: "info.circle") { showsSheet = true }
                                .buttonStyle(MotionButtonStyle(.secondary, expandsHorizontally: true))

                            Button("Clear items", systemImage: "trash", role: .destructive) { count = 0 }
                                .buttonStyle(MotionButtonStyle(.destructive, expandsHorizontally: true))
                                .disabled(count == 0)
                        }
                    }

                    MotionCard {
                        VStack(alignment: .leading, spacing: theme.spacing.standard) {
                            Text("Filters").font(theme.typography.sectionTitle)
                            ViewThatFits(in: .horizontal) {
                                HStack(spacing: theme.spacing.small) { filters }
                                VStack(alignment: .leading, spacing: theme.spacing.small) { filters }
                            }
                            Text(showsFavorites ? "Showing favorite items." : "Showing all items.")
                                .font(theme.typography.supporting)
                                .foregroundStyle(theme.colors.secondaryText)
                            MotionDisclosure("About these filters", isExpanded: $detailsExpanded) {
                                Text("Favorites keep frequently used items close. Available offline limits the list to items already stored on this device.")
                                    .font(theme.typography.body)
                                    .foregroundStyle(theme.colors.secondaryText)
                            }
                        }
                    }

                    MotionCard {
                        VStack(alignment: .leading, spacing: theme.spacing.standard) {
                            Text("Save flow preview").font(theme.typography.sectionTitle)
                            MotionStatusLabel(saveMessage, status: saveStatus)
                            MotionAsyncButton("Preview save", loadingTitle: "Saving…") {
                                // A cancellable local delay makes the busy state inspectable.
                                saveStatus = .loading
                                saveMessage = "Running the local save preview…"
                                defer {
                                    if Task.isCancelled {
                                        saveStatus = .info
                                        saveMessage = "Save preview cancelled."
                                    }
                                }
                                try await Task.sleep(for: .milliseconds(800))
                                try Task.checkCancellation()
                                saveStatus = .success
                                saveMessage = "Save preview complete."
                            } onError: { _ in
                                saveStatus = .error
                                saveMessage = "The save preview failed. Try again."
                            }
                            MotionStatusLabel("Offline mode is available.", status: .info)
                            MotionStatusLabel("Your storage is nearly full.", status: .warning)
                            MotionStatusLabel("A sample upload needs your attention.", status: .error)
                        }
                    }
                }
                .padding(theme.spacing.standard)
                .frame(maxWidth: MotionTheme.Layout.maximumReadableWidth)
                .frame(maxWidth: .infinity)
            }
            .background(theme.colors.background)
            .navigationTitle("Motion showcase")
            .sheet(isPresented: $showsSheet) {
                NavigationStack {
                    Text("System sheets keep native presentation, dismissal, and accessibility behavior.")
                        .font(theme.typography.body)
                        .padding(theme.spacing.large)
                        .navigationTitle("Details")
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Done") { showsSheet = false }
                            }
                        }
                }
                .presentationDetents([.medium, .large])
            }
        }
    }

    @ViewBuilder private var filters: some View {
        MotionChip("Favorites", isSelected: $showsFavorites)
        MotionChip("Available offline", isSelected: $showsOffline)
    }
}

struct MotionShowcase_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MotionShowcase()
                .motionTheme(.native)
                .preferredColorScheme(.light)
                .previewDisplayName("Native · Light")

            MotionShowcase()
                .motionTheme(.calm)
                .preferredColorScheme(.dark)
                .previewDisplayName("Calm · Dark")

            MotionShowcase()
                .motionTheme(.expressive)
                .dynamicTypeSize(.accessibility3)
                .previewDisplayName("Expressive · Accessibility")

            MotionShowcase()
                .motionTheme(MotionTheme(reduceMotion: true))
                .previewDisplayName("Reduced Motion · App Preference")
        }
    }
}
