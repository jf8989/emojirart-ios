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
    @State private var isDraggingSelection = false  // hides chrome while dragging
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
                        // Live drag for entire selection (shared offset), commit on end
                        .draggableIfSelected(
                            isSelected: isSelected,
                            modelZoom: vm.ui.zoom,
                            selectionIDs: { vm.selection.ids },
                            liveSelectionOffset: $selectionDragOffset,
                            onMoveSelectionBy: onMoveSelectionBy,
                            onDraggingChange: { isDraggingSelection = $0 }
                        )
                        // Tap to select / double‑tap to delete / context menu
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
    }

    // MARK: - Derived viewport
    private var currentPan: CGSize {
        CanvasViewport.pan(vm.ui.pan, panDragViewOffset)
    }
    private var currentZoom: CGFloat {
        CanvasViewport.zoom(vm.ui.zoom, pinchScale)
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
