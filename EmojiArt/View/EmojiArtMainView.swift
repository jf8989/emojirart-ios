// View/EmojiArtMainView.swift

import SwiftUI

/// Main container view. Hosts the canvas and palette chooser with toolbar actions.

struct EmojiArtMainView: View {
    @StateObject private var vm = EmojiArtViewModel()
    @StateObject private var paletteStore = PaletteStoreViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                CanvasView(
                    vm: vm,
                    emojiGroup: vm.elementsOnCanvas.emojisOnCanvas,
                    onMoveSelectionBy: { ids, delta in
                        vm.move(ids, by: delta)
                    },
                    onScaleSelectionBy: { ids, factor in
                        vm.scale(ids, by: factor)
                    },
                    onRemoveSelection: { ids in vm.remove(ids) }
                )
                Divider()
                paletteChooser
            }
            .navigationTitle("EmojiArt")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Reset View") {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            vm.ui.pan = .zero
                            vm.ui.zoom = 1
                        }
                        vm.selection.clear()
                        vm.resetCanvas()
                    }
                }
            }
        }
        .environmentObject(paletteStore)
    }

    // MARK: - Sub.Views
    private var paletteChooser: some View {
        PaletteChooser { pickedEmoji in
            vm.addEmoji(pickedEmoji, at: .zero)
        }
    }
}
