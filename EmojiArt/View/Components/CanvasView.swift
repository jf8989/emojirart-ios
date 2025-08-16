// View/Components/CanvasView.swift

import SwiftUI
import UIKit

struct CanvasView: View {

    // MARK: - Inputs (single VM)
    @ObservedObject var vm: EmojiArtViewModel
    let emojiGroup: [Emoji]
    let onMoveSelectionBy: (_ ids: Set<UUID>, _ modelDelta: CGSize) -> Void
    let onScaleSelectionBy: (_ ids: Set<UUID>, _ factor: CGFloat) -> Void
    let onRemoveSelection: (_ ids: Set<UUID>) -> Void

    // MARK: - Gesture/Live UI State
    @GestureState private var panDragViewOffset: CGSize = .zero  // in-flight doc pan
    @State private var pinchScale: CGFloat = 1  // in-flight pinch
    @State private var selectionDragOffset: CGSize = .zero  // shared live offset for multi-select drag
    @State private var isPinching: Bool = false

    // MARK: - Viewport (combined pan/zoom injected for children)
    @Environment(\.canvasViewport) private var viewport

    var body: some View { canvasPlayground }

    var canvasPlayground: some View {
        GeometryReader { geo in
            ZStack {
                // MARK: - Background
                Color.primary.ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onTapGesture { vm.selection.clear() }

                // MARK: - Images Layer
                ForEach(vm.canvas.images) { img in
                    ImageNodeView(
                        vm: vm,
                        item: img,
                        pinchScale: $pinchScale,
                        canvasSize: geo.size,
                        selectionDragOffset: $selectionDragOffset,
                        onMoveSelectionBy: onMoveSelectionBy,
                        onRequestDelete: { vm.ui.showDeleteConfirm = true }
                    )
                }

                // MARK: - Emoji Layer
                ForEach(emojiGroup) { e in
                    EmojiNodeView(
                        vm: vm,
                        emoji: e,
                        pinchScale: $pinchScale,
                        canvasSize: geo.size,
                        selectionDragOffset: $selectionDragOffset,
                        onMoveSelectionBy: onMoveSelectionBy,
                        onRequestDelete: { vm.ui.showDeleteConfirm = true }
                    )
                }
            }
            // Drops (images / URLs)
            .canvasDrops(vm: vm, canvasSize: geo.size, viewport: viewport)

            // Pan + Zoom gestures
            .canvasPanZoom(
                vm: vm,
                selectionDragOffset: $selectionDragOffset,
                pinchScale: $pinchScale,
                isPinching: $isPinching,
                panDragViewOffset: $panDragViewOffset,
                onScaleSelectionBy: onScaleSelectionBy
            )
        }
        // Deletion alert
        .canvasDeletionAlert(
            title:
                "Delete selected item\(vm.selection.ids.count > 1 ? "s" : "")?",
            isPresented: $vm.ui.showDeleteConfirm,
            onDelete: {
                onRemoveSelection(vm.selection.ids)
                vm.selection.clear()
                vm.ui.didDelete.toggle()
                Haptics.success()
            }
        )
        .withSensoryFeedback(
            selectionTrigger: vm.selection.ids.count,
            deleteTrigger: vm.ui.didDelete
        )
        // Provide combined pan/zoom to children via Environment (uses live states above)
        .provideCanvasViewport(
            persistedPan: vm.ui.pan,
            livePan: panDragViewOffset,
            persistedZoom: vm.ui.zoom,
            pinchScale: pinchScale
        )
    }
}
