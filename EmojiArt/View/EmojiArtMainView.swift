import SwiftUI

struct EmojiArtMainView: View {
    @StateObject private var viewModel = EmojiArtViewModel()
    @StateObject private var selectionViewModel = SelectionViewModel()
    /// pan / zoom
    @StateObject private var canvasUI = CanvasUIState()

    // MARK: - Body View

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                CanvasView(
                    selectionViewModel: selectionViewModel,
                    canvasUI: canvasUI,
                    emojiGroup: viewModel.canvas.emojiGroup,
                    onMoveSelectionBy: { ids, modelDelta in
                        viewModel.move(ids, by: modelDelta)
                    },
                    onScaleSelectionBy: { ids, factor in
                        viewModel.scale(ids, by: factor)
                    },
                    onRemoveSelection: { ids in viewModel.remove(ids) }
                )
                Divider()
                paletteView
            }
            .navigationTitle("EmojiArt")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Reset View") {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            canvasUI.pan = .zero
                            canvasUI.zoom = 1
                        }
                        selectionViewModel.clear()
                        viewModel.resetCanvas() // remove all emojis
                    }
                }
            }
        }
    }

    // MARK: - Sub.Views

    var paletteView: some View {
        /// Appends any selected emoji to the canvas
        PaletteView { pickedEmoji in
            viewModel.addEmoji(pickedEmoji, at: .zero)
        }
    }
}

#Preview {
    EmojiArtMainView()
}
