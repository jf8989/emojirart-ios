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
    @GestureState private var pinchScale: CGFloat = 1  // in-flight pinch
    @State private var selectionDragOffset: CGSize = .zero  // shared live offset for multi-select drag

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
                        pinchScale: pinchScale,
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
                        pinchScale: pinchScale,
                        canvasSize: geo.size,
                        selectionDragOffset: $selectionDragOffset,
                        onMoveSelectionBy: onMoveSelectionBy,
                        onRequestDelete: { vm.ui.showDeleteConfirm = true }
                    )
                }
            }
            // Modern Drop Targets
            .dropDestination(for: DroppedImage.self) { items, location in
                let modelPoint = CanvasGeometry.modelPoint(
                    fromView: location,
                    pan: viewport.pan,
                    zoom: viewport.zoom,
                    canvasSize: geo.size
                )
                let initialSize: CGFloat = (120 / max(viewport.zoom, 0.001))
                    .clamped(to: 40...512)
                for item in items {
                    if case .data(let data) = item.source,
                        vm.isAcceptableImage(data)
                    {
                        vm.addImage(
                            data: data,
                            at: modelPoint,
                            size: initialSize
                        )
                    }
                }
                return true
            }
            .dropDestination(for: URL.self) { urls, location in
                let modelPoint = CanvasGeometry.modelPoint(
                    fromView: location,
                    pan: viewport.pan,
                    zoom: viewport.zoom,
                    canvasSize: geo.size
                )
                let initialSize: CGFloat = (120 / max(viewport.zoom, 0.001))
                    .clamped(to: 40...512)
                for url in urls {
                    if url.isFileURL {
                        if let data = try? Data(contentsOf: url),
                            vm.isAcceptableImage(data)
                        {
                            vm.addImage(
                                data: data,
                                at: modelPoint,
                                size: initialSize
                            )
                        }
                    } else {
                        Task {
                            do {
                                let (data, _) = try await URLSession.shared
                                    .data(from: url)
                                if vm.isAcceptableImage(data) {
                                    await MainActor.run {
                                        vm.addImage(
                                            data: data,
                                            at: modelPoint,
                                            size: initialSize
                                        )
                                    }
                                }
                            } catch { /* ignore */  }
                        }
                    }
                }
                return true
            }
            // Combined pan + zoom at the canvas root
            .simultaneousGesture(combinedPanZoom)
        }
        // Alert & Feedback
        .alert(
            "Delete selected item\(vm.selection.ids.count > 1 ? "s" : "")?",
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
        // Provide combined pan/zoom to children via Environment (uses live states above)
        .provideCanvasViewport(
            persistedPan: vm.ui.pan,
            livePan: panDragViewOffset,
            persistedZoom: vm.ui.zoom,
            pinchScale: pinchScale
        )
    }

    // MARK: - Combined Gestures (Pan ⨉ Zoom)
    private var combinedPanZoom: some Gesture {
        let magnify = MagnificationGesture()
            .updating($pinchScale) { value, state, _ in
                state = value
            }
            .onEnded { final in
                if vm.selection.ids.isEmpty {
                    vm.ui.zoom = min(max(vm.ui.zoom * final, 0.25), 8.0)
                } else {
                    onScaleSelectionBy(vm.selection.ids, final)
                }
            }

        let pan = DragGesture()
            .updating($panDragViewOffset) { value, state, _ in
                // Only pan the document when NOT dragging a selection
                if vm.selection.ids.isEmpty && selectionDragOffset == .zero {
                    state = value.translation
                }
            }
            .onEnded { value in
                if vm.selection.ids.isEmpty && selectionDragOffset == .zero {
                    vm.ui.pan.width += value.translation.width
                    vm.ui.pan.height += value.translation.height
                }
            }

        return magnify.simultaneously(with: pan)
    }
}
