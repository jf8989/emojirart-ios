// View/Components/ImageNodeView.swift

import SwiftUI
import UIKit

struct ImageNodeView: View {
    @ObservedObject var vm: EmojiArtViewModel
    let item: CanvasImage
    let pinchScale: CGFloat
    let canvasSize: CGSize
    @Binding var selectionDragOffset: CGSize
    let onMoveSelectionBy: (_ ids: Set<UUID>, _ modelDelta: CGSize) -> Void
    let onRequestDelete: () -> Void

    @Environment(\.canvasViewport) private var viewport
    @State private var isDraggingSelection = false

    var body: some View {
        let isSelected = vm.isSelected(item.id)
        let isInteracting = isDraggingSelection || (abs(pinchScale - 1) > 0.001)

        let minRenderedSize: CGFloat = 30
        let docScale = vm.selection.ids.isEmpty ? viewport.zoom : vm.ui.zoom
        let required =
            minRenderedSize / max(item.size * max(docScale, 0.001), 0.001)
        let livePinchForSelection: CGFloat =
            (isSelected && !vm.selection.ids.isEmpty)
            ? max(pinchScale, required) : 1

        if let uiImage = UIImage(data: item.data) {
            Image(uiImage: uiImage)
                .resizable()
                .interpolation(.medium)
                .scaledToFit()
                .frame(width: item.size, height: item.size)  // base size
                .selectionChrome(  // same outline behavior
                    isSelected: isSelected,
                    isInteracting: isInteracting,
                    cornerRadius: 6,
                    lineWidth: 2
                )
                .scaleEffect(docScale * livePinchForSelection)  // doc zoom or live selection pinch
                .position(
                    CanvasGeometry.viewPoint(
                        fromModel: item.position,
                        pan: viewport.pan,
                        zoom: docScale,
                        canvasSize: canvasSize
                    )
                )
                .draggableIfSelected(  // reuse modifier
                    isSelected: isSelected,
                    modelZoom: vm.ui.zoom,
                    selectionIDs: { vm.selection.ids },
                    liveSelectionOffset: $selectionDragOffset,
                    onMoveSelectionBy: onMoveSelectionBy,
                    onDraggingChange: { isDraggingSelection = $0 }
                )
                .selectionInteractions(  // tap to select, double-tap delete
                    isSelected: isSelected,
                    onSelect: {
                        vm.selection.toggle(item.id)
                        Haptics.selection()
                    },
                    onRequestDelete: onRequestDelete
                )
                .animation(nil, value: isInteracting)  // prevent jitter mid-gesture
                .animation(nil, value: selectionDragOffset)  // smooth multi-select drag
                .zIndex(
                    isSelected
                        ? CanvasZ.imagesBase + CanvasZ.imagesSelectedBump
                        : CanvasZ.imagesBase
                )
        }
    }
}
