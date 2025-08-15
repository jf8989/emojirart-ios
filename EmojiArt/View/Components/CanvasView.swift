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
    @GestureState private var panDragViewOffset: CGSize = .zero
    @GestureState private var emojiDragViewOffset: CGSize = .zero
    @GestureState private var pinchScale: CGFloat = 1

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
                        .padding(2)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(
                                    showSelectionChrome ? Color.blue : .clear,
                                    lineWidth: 2
                                )
                                .opacity(
                                    showSelectionChrome && !isInteracting
                                        ? 1 : 0
                                )
                        )
                        .animation(nil, value: isInteracting)
                        .scaleEffect(docScale * livePinchForSelection)
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
                        .onTapGesture {
                            if !showSelectionChrome {
                                vm.selection.toggle(e.id)
                                Haptics.selection()
                            }
                        }
                        .onTapGesture(count: 2) {
                            if showSelectionChrome {
                                vm.ui.showDeleteConfirm = true
                            }
                        }
                        .gesture(showSelectionChrome ? emojiDragGesture : nil)
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
        .gesture(magnifyGesture)
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

    private var magnifyGesture: some Gesture {
        MagnificationGesture()
            .updating($pinchScale) { value, state, _ in state = value }
            .onEnded { final in
                if vm.selection.ids.isEmpty {
                    vm.ui.zoom = min(max(vm.ui.zoom * final, 0.25), 8.0)
                } else {
                    onScaleSelectionBy(vm.selection.ids, final)
                }
            }
    }
}

// MARK: - Sensory Feedback (unchanged)
extension View {
    @ViewBuilder
    fileprivate func withSensoryFeedback(
        selectionTrigger: Int,
        deleteTrigger: Bool
    ) -> some View {
        if #available(iOS 17.0, *) {
            self
                .sensoryFeedback(.selection, trigger: selectionTrigger)
                .sensoryFeedback(.success, trigger: deleteTrigger)
        } else {
            self
        }
    }
}
