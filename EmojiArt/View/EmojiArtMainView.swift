// View/EmojiArtMainView.swift

import SwiftUI

struct EmojiArtMainView: View {
    @StateObject private var viewModel = EmojiArtViewModel()
    @StateObject private var selectionViewModel = SelectionViewModel()
    @StateObject private var canvasUI = CanvasUIState()
    /// pan / zoom

    // MARK: - Body View

    var body: some View {
        VStack(spacing: 0) {
            CanvasView(
                selectionViewModel: selectionViewModel,
                canvasUI: canvasUI,
                emojiGroup: viewModel.canvas.emojiGroup,
                onMoveSelectionBy: { ids, modelDelta in
                    viewModel.move(ids, by: modelDelta)
                },
                onScaleSelectionBy: {
                    ids,
                    factor in viewModel.scale(ids, by: factor)
                }
            )
            Divider()
            paletteView
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
