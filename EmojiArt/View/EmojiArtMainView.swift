// View/EmojiArtMainView.swift

import SwiftUI

struct EmojiArtMainView: View {
    @StateObject private var viewModel = EmojiArtViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                CanvasView(
                    vm: viewModel,
                    emojiGroup: viewModel.canvas.emojiGroup,
                    onMoveSelectionBy: { ids, delta in
                        viewModel.move(ids, by: delta)
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
                            viewModel.ui.pan = .zero
                            viewModel.ui.zoom = 1
                        }
                        viewModel.selection.clear()
                        viewModel.resetCanvas()
                    }
                }
            }
        }
    }

    // MARK: - Sub.Views
    var paletteView: some View {
        PaletteView { pickedEmoji in
            viewModel.addEmoji(pickedEmoji, at: .zero)
        }
    }
}
