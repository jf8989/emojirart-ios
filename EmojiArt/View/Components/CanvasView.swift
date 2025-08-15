// View/Components/CanvasView.swift

import SwiftUI

struct CanvasView: View {

    // MARK: - Inputs (now single VM)
    @ObservedObject var vm: EmojiArtViewModel
    let emojiGroup: [Emoji]
    let onMoveSelectionBy: (_ ids: Set<UUID>, _ modelDelta: CGSize) -> Void
    let onScaleSelectionBy: (_ ids: Set<UUID>, _ factor: CGFloat) -> Void
    let onRemoveSelection: (_ ids: Set<UUID>) -> Void

    // MARK: - Gesture/Live UI State
    @GestureState private var panDragViewOffset: CGSize = .zero
    @State private var pinchScale: CGFloat = 1
    @State private var isDraggingSelection = false  // for chrome hide during drag

    var body: some View { canvasPlayground }

    var canvasPlayground: some View {
        GeometryReader { geo in
            ZStack {
                // Background
                Color.white.ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onTapGesture { vm.selection.clear() }
                    .gesture(
                        vm.selection.ids.isEmpty ? backgroundPanGesture : nil
                    )

                // Emoji Layer
                ForEach(emojiGroup) { e in
                    let isSelected = vm.isSelected(e.id)
                    let isInteracting =
                        isDraggingSelection || (abs(pinchScale - 1) > 0.001)

                    let minRenderedSize: CGFloat = 30
                    let docScale =
                        vm.selection.ids.isEmpty ? currentZoom : vm.ui.zoom
                    let required =
                        minRenderedSize
                        / max(e.size * max(docScale, 0.001), 0.001)
                    let livePinchForSelection: CGFloat =
                        (isSelected && !vm.selection.ids.isEmpty)
                        ? max(pinchScale, required) : 1

                    Text(e.text)
                        .accessibilityLabel(Text(e.text))
                        .accessibilityHint(
                            "Tap to select. Drag to move when selected. Double‑tap to delete."
                        )
                        .font(.system(size: e.size))
                        .selectionChrome(
                            isSelected: isSelected,
                            isInteracting: isInteracting,
                            cornerRadius: 4,
                            lineWidth: 2
                        )
                        .scaleEffect(docScale * livePinchForSelection)
                        .position(
                            CanvasGeometry.viewPoint(
                                fromModel: e.position,
                                pan: currentPan,
                                zoom: vm.selection.ids.isEmpty
                                    ? currentZoom : vm.ui.zoom,
                                canvasSize: geo.size
                            )
                        )
                        // Per‑emoji drag (only when selected), with live offset + commit
                        .draggableIfSelected(
                            isSelected: isSelected,
                            modelZoom: vm.ui.zoom,
                            selectionIDs: { vm.selection.ids },
                            onMoveSelectionBy: onMoveSelectionBy,
                            onDraggingChange: { isDragging in
                                isDraggingSelection = isDragging
                            }
                        )
                        // Tap/double‑tap/context menu (unchanged behavior)
                        .selectionInteractions(
                            isSelected: isSelected,
                            onSelect: {
                                vm.selection.toggle(e.id)
                                Haptics.selection()
                            },
                            onRequestDelete: { vm.ui.showDeleteConfirm = true }
                        )
                        .zIndex(isSelected ? 1 : 0)
                }
            }
        }
        // Alert (flags now in vm.ui)
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
        // Pinch handling via modifier (no overlay; doesn’t block taps)
        .canvasGestures(
            vm: vm,
            livePinchScale: $pinchScale,
            onScaleSelectionBy: onScaleSelectionBy
        )
    }

    // MARK: - Derived pan (persisted + in-flight)
    private var currentPan: CGSize {
        .init(
            width: vm.ui.pan.width + panDragViewOffset.width,
            height: vm.ui.pan.height + panDragViewOffset.height
        )
    }
    private var currentZoom: CGFloat { vm.ui.zoom * pinchScale }

    // MARK: - Gestures (background only; per-emoji drag lives in modifier)
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
