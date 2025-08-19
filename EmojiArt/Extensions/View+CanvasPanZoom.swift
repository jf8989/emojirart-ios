// Extensions/View+CanvasPanZoom.swift

import SwiftUI

/// It provides a reusable modifier that combines pinch-to-zoom and drag-to-pan gestures for the canvas.

extension View {
    func canvasPanZoom(
        vm: EmojiArtViewModel,
        selectionDragOffset: Binding<CGSize>,
        pinchScale: Binding<CGFloat>,
        isPinching: Binding<Bool>,
        panDragViewOffset: GestureState<CGSize>,
        onScaleSelectionBy: @escaping (_ ids: Set<UUID>, _ factor: CGFloat) ->
            Void
    ) -> some View {

        // Magnify (pinch)
        let magnify = MagnificationGesture()
            .onChanged { value in
                isPinching.wrappedValue = true
                pinchScale.wrappedValue = value
            }
            .onEnded { final in
                if vm.selection.ids.isEmpty {
                    vm.ui.zoom = min(max(vm.ui.zoom * final, 0.25), 8.0)
                } else {
                    onScaleSelectionBy(vm.selection.ids, final)
                }
                // Defer reset to next runloop to avoid stale gesture state
                DispatchQueue.main.async {
                    pinchScale.wrappedValue = 1
                    isPinching.wrappedValue = false
                }
            }

        // Pan (background only when not dragging a selection)
        let pan = DragGesture()
            .updating(panDragViewOffset) { value, state, _ in
                if vm.selection.ids.isEmpty
                    && selectionDragOffset.wrappedValue == .zero
                {
                    state = value.translation
                }
            }
            .onEnded { value in
                if vm.selection.ids.isEmpty
                    && selectionDragOffset.wrappedValue == .zero
                {
                    vm.ui.pan.width += value.translation.width
                    vm.ui.pan.height += value.translation.height
                }
            }

        return self.simultaneousGesture(magnify.simultaneously(with: pan))
    }
}
