// View/EmojiArtMainView.swift

import SwiftUI

struct EmojiArtMainView: View {
    @StateObject private var viewModel = EmojiArtViewModel()
    @StateObject private var selectionViewModel = SelectionViewModel()

    // MARK: - Body View

    var body: some View {
        CanvasView(
            selectionViewModel: selectionViewModel,
            emojis: viewModel.canvas.emojis,
            pan: .zero,
            zoom: 1
        )
        Divider()
        paletteView
    }

    // MARK: - Sub.Views

    var paletteView: some View {
        PaletteView { picked in
            viewModel.addEmoji(picked, at: .zero)/// center
        }
    }
}

#Preview {
    EmojiArtMainView()
}
