// View/Components/CanvasView.swift

import SwiftUI

struct CanvasView: View {

    // MARK: - Inputs (now single VM)
    @ObservedObject var vm: EmojiArtViewModel
    let emojiGroup: [Emoji]
    let onMoveSelectionBy: (_ ids: Set<UUID>, _ modelDelta: CGSize) -> Void
    let onScaleSelectionBy: (_ ids: Set<UUID>, _ factor: CGFloat) -> Void
    let onRemoveSelection: (_ ids: Set<UUID>) -> Void

    // MARK: - Gesture State

    /// Per-emoji drag stays local.
    @GestureState private var emojiDragViewOffset: CGSize = .zero
    /// Live background pan delta (view space)
    @GestureState private var panDragViewOffset: CGSize = .zero
    /// Live pinch scale (fed by modifier)
    @State private var pinchScale: CGFloat = 1

    var body: some View { canvasPlayground }

    var canvasPlayground: some View {
        GeometryReader { geo in
            ZStack {
                // MARK: - Background Layer
                Color.white.ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onTapGesture { vm.selection.clear() }
                    .gesture(
                        vm.selection.ids.isEmpty ? backgroundPanGesture : nil
                    )

                // MARK: - Emoji Layer
                ForEach(emojiGroup) { e in
                    let showSelectionChrome = vm.isSelected(e.id)
                    let isInteracting =
                        (emojiDragViewOffset != .zero)
                        || (abs(pinchScale - 1) > 0.001)

                    let minRenderedSize: CGFloat = 30
                    let docScale =
                        vm.selection.ids.isEmpty ? currentZoom : vm.ui.zoom
                    let required =
                        minRenderedSize
                        / max(e.size * max(docScale, 0.001), 0.001)
                    let livePinchForSelection: CGFloat =
                        (showSelectionChrome && !vm.selection.ids.isEmpty)
                        ? max(pinchScale, required) : 1

                    Text(e.text)
                        .accessibilityLabel(Text(e.text))
                        .accessibilityHint(
                            "Tap to select. Drag to move when selected. Double‑tap to delete."
                        )
                        .font(.system(size: e.size))
                        .selectionChrome(
                            isSelected: showSelectionChrome,
                            isInteracting: isInteracting,
                            cornerRadius: 4,
                            lineWidth: 2
                        )
                        // Live scale: document or selection branch
                        .scaleEffect(docScale * livePinchForSelection)
                        // Live drag offset while moving selection
                        .offset(
                            showSelectionChrome ? emojiDragViewOffset : .zero
                        )
                        .zIndex(showSelectionChrome ? 1 : 0)
                        .position(
                            CanvasGeometry.viewPoint(
                                fromModel: e.position,
                                pan: currentPan,
                                zoom: vm.selection.ids.isEmpty
                                    ? currentZoom : vm.ui.zoom,
                                canvasSize: geo.size
                            )
                        )
                        // Tap to select (no toggle-off on tap when selected)
                        .onTapGesture {
                            if !showSelectionChrome {
                                vm.selection.toggle(e.id)
                                Haptics.selection()
                            }
                        }
                        // Double-tap to confirm delete
                        .onTapGesture(count: 2) {
                            if showSelectionChrome {
                                vm.ui.showDeleteConfirm = true
                            }
                        }
                        // Drag only when selected
                        .gesture(showSelectionChrome ? emojiDragGesture : nil)
                        // Context menu on long-press
                        .contextMenu {
                            if showSelectionChrome {
                                Button(role: .destructive) {
                                    vm.ui.showDeleteConfirm = true
                                } label: {
                                    Label(
                                        "Delete Selected",
                                        systemImage: "trash"
                                    )
                                }
                            }
                        }
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

    // MARK: - Gestures

    private var emojiDragGesture: some Gesture {
        DragGesture()
            .updating($emojiDragViewOffset) { value, state, _ in
                state = value.translation
            }
            .onEnded { value in
                let modelDelta = CanvasGeometry.modelDelta(
                    fromViewDelta: value.translation,
                    zoom: vm.ui.zoom
                )
                onMoveSelectionBy(vm.selection.ids, modelDelta)
            }
    }

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
