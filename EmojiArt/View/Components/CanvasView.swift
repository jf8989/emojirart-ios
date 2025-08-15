// View/Components/CanvasView.swift

import SwiftUI

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

    var body: some View { canvasPlayground }

    var canvasPlayground: some View {
        GeometryReader { geo in
            ZStack {
                // MARK: - Background
                Color.white.ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onTapGesture { vm.selection.clear() }
                    .gesture(
                        vm.selection.ids.isEmpty ? backgroundPanGesture : nil
                    )

                // MARK: - Emoji Layer
                ForEach(emojiGroup) { e in
                    EmojiNodeView(
                        vm: vm,
                        emoji: e,
                        pinchScale: pinchScale,
                        canvasSize: geo.size,
                        selectionDragOffset: $selectionDragOffset,
                        onMoveSelectionBy: onMoveSelectionBy,
                        onRequestDelete: { vm.ui.showDeleteConfirm = true }
                    )
                }
            }
        }
        // MARK: - Alert & Feedback
        .alert(
            "Delete selected emoji\(vm.selection.ids.count > 1 ? "s" : "")?",
            isPresented: $vm.ui.showDeleteConfirm
        ) {
            Button("Delete", role: .destructive) {
                onRemoveSelection(vm.selection.ids)
                vm.selection.clear()
                vm.ui.didDelete.toggle()
                Haptics.success()
            }
            Button("Cancel", role: .cancel) {}
        }
        .withSensoryFeedback(
            selectionTrigger: vm.selection.ids.count,
            deleteTrigger: vm.ui.didDelete
        )
        // Pinch handling (doc zoom or selection scale)
        .canvasGestures(
            vm: vm,
            livePinchScale: $pinchScale,
            onScaleSelectionBy: onScaleSelectionBy
        )
        // Provide combined pan/zoom to children via Environment
        .provideCanvasViewport(
            persistedPan: vm.ui.pan,
            livePan: panDragViewOffset,
            persistedZoom: vm.ui.zoom,
            pinchScale: pinchScale
        )
    }

    // MARK: - Gestures
    private var backgroundPanGesture: some Gesture {
        DragGesture()
            .updating($panDragViewOffset) { value, state, _ in
                state = value.translation
            }
            .onEnded { value in
                vm.ui.pan.width += value.translation.width
                vm.ui.pan.height += value.translation.height
            }
    }
}
