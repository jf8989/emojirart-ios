// View/EmojiArtMainView.swift

import SwiftUI

/// Main container view. Hosts the canvas and palette chooser with toolbar actions.

struct EmojiArtMainView: View {
    @StateObject private var viewModel = EmojiArtViewModel()
    @StateObject private var paletteStore = PaletteStoreViewModel()

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
                paletteChooser
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
        .environmentObject(paletteStore)
    }

    // MARK: - Sub.Views
    private var paletteChooser: some View {
        PaletteChooser { pickedEmoji in
            viewModel.addEmoji(pickedEmoji, at: .zero)
        }
    }
}
