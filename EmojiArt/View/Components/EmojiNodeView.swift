// View/Components/EmojiNodeView.swift

import SwiftUI

struct EmojiNodeView: View {
    @ObservedObject var vm: EmojiArtViewModel
    let emoji: Emoji
    let pinchScale: CGFloat
    let currentPan: CGSize
    let currentZoom: CGFloat
    let canvasSize: CGSize
    @Binding var selectionDragOffset: CGSize
    let onMoveSelectionBy: (_ ids: Set<UUID>, _ modelDelta: CGSize) -> Void
    let onRequestDelete: () -> Void

    @State private var isDraggingSelection = false

    var body: some View {
        let isSelected = vm.isSelected(emoji.id)
        let isInteracting = isDraggingSelection || (abs(pinchScale - 1) > 0.001)

        let minRenderedSize: CGFloat = 30
        let docScale = vm.selection.ids.isEmpty ? currentZoom : vm.ui.zoom
        let required =
            minRenderedSize / max(emoji.size * max(docScale, 0.001), 0.001)
        let livePinchForSelection: CGFloat =
            (isSelected && !vm.selection.ids.isEmpty)
            ? max(pinchScale, required) : 1

        Text(emoji.text)
            .accessibilityLabel(Text(emoji.text))
            .accessibilityHint(
                "Tap to select. Drag to move when selected. Double‑tap to delete."
            )
            .font(.system(size: emoji.size))
            .selectionChrome(
                isSelected: isSelected,
                isInteracting: isInteracting,
                cornerRadius: 4,
                lineWidth: 2
            )
            .scaleEffect(docScale * livePinchForSelection)
            .position(
                CanvasGeometry.viewPoint(
                    fromModel: emoji.position,
                    pan: currentPan,
                    zoom: vm.selection.ids.isEmpty ? currentZoom : vm.ui.zoom,
                    canvasSize: canvasSize
                )
            )
            .draggableIfSelected(
                isSelected: isSelected,
                modelZoom: vm.ui.zoom,
                selectionIDs: { vm.selection.ids },
                liveSelectionOffset: $selectionDragOffset,
                onMoveSelectionBy: onMoveSelectionBy,
                onDraggingChange: { isDraggingSelection = $0 }
            )
            .selectionInteractions(
                isSelected: isSelected,
                onSelect: {
                    vm.selection.toggle(emoji.id)
                    Haptics.selection()
                },
                onRequestDelete: onRequestDelete
            )
            .zIndex(isSelected ? 1 : 0)
    }
}
