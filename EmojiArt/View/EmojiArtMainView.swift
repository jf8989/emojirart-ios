// View/EmojiArtMainView.swift

import SwiftUI

struct EmojiArtMainView: View {
    @StateObject private var viewModel = EmojiArtViewModel()
    @StateObject private var selectionViewModel = SelectionViewModel()

    // MARK: - Body View

    var body: some View {
        CanvasView(
            selectionViewModel: selectionViewModel,
            emojiGroup: viewModel.canvas.emojiGroup,
            pan: .zero,
            zoom: 1
        )
        Divider()
        paletteView
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
