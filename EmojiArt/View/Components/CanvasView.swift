// View/Components/CanvasView.swift

import SwiftUI

struct CanvasView: View {

    // MARK: - Inputs

    @ObservedObject var selectionViewModel: SelectionViewModel
    @ObservedObject var canvasUI: CanvasUIState
    @State private var showDeleteConfirm: Bool = false
    @State private var didDelete = false
    let emojiGroup: [Emoji]
    let onMoveSelectionBy: (_ ids: Set<UUID>, _ modelDelta: CGSize) -> Void
    let onScaleSelectionBy: (_ ids: Set<UUID>, _ factor: CGFloat) -> Void
    let onRemoveSelection: (_ ids: Set<UUID>) -> Void

    // MARK: - Gesture State

    /// view-space delta during background pan
    @GestureState private var panDragViewOffset: CGSize = .zero
    /// view-space delta during emoji drag
    @GestureState private var emojiDragViewOffset: CGSize = .zero
    @GestureState private var pinchScale: CGFloat = 1

    // MARK: - Body View

    var body: some View {
        canvasPlayground
    }

    var canvasPlayground: some View {
        GeometryReader { geo in
            ZStack {

                // MARK: - Background Layer

                /// Builds the white background
                Color.white.ignoresSafeArea()
                    .contentShape(Rectangle())
                    /// Background tap clears selection
                    .onTapGesture { selectionViewModel.clear() }
                    /// Background drag pans the document ONLY when nothing is selected
                    .gesture(
                        selectionViewModel.ids.isEmpty
                            ? backgroundPanGesture : nil
                    )

                // MARK: - Emoji Layer

                /// Only those with a diff get redrawn
                ForEach(emojiGroup) { e in
                    let showSelectionChrome = selectionViewModel.contains(e.id)
                    let isInteracting =
                        (emojiDragViewOffset != .zero)
                        || (abs(pinchScale - 1) > 0.001)
                    Text(e.text)
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
                        /// Live scale for selected emojis when pinching with a selection
                        .scaleEffect(
                            /// Base = document zoom (live during no-selection pinch, persisted otherwise)
                            (selectionViewModel.ids.isEmpty
                                ? currentZoom : canvasUI.zoom)
                                /// If selecting, multipply ONLY selected glyphs by live pinch
                                * (showSelectionChrome
                                    && !selectionViewModel.ids.isEmpty
                                    ? pinchScale : 1)
                        )
                        /// live offset while dragging selection
                        .offset(
                            showSelectionChrome ? emojiDragViewOffset : .zero
                        )
                        .zIndex(showSelectionChrome ? 1 : 0)
                        .position(
                            CanvasGeometry
                                .viewPoint(
                                    fromModel: e.position,
                                    pan: currentPan,
                                    /// zoom doc live only when NO selection is made (selection path scales glyphs instead)
                                    zoom: selectionViewModel.ids.isEmpty
                                        ? currentZoom : canvasUI.zoom,
                                    canvasSize: geo.size
                                )
                        )
                        /// Emoji tap: toggles selection if not selected; does nothing if already selected (prevents unselect on tap)
                        .onTapGesture {
                            if !showSelectionChrome {
                                selectionViewModel.toggle(e.id)
                                Haptics.selection()
                            }
                        }
                        /// Double-tap triggers delete confirmation dialog if selected
                        .onTapGesture(count: 2) {
                            if showSelectionChrome {
                                showDeleteConfirm = true
                            }
                        }
                        .gesture(showSelectionChrome ? emojiDragGesture : nil)
                        /// Long-press context menu
                        .contextMenu {
                            if showSelectionChrome {
                                Button(role: .destructive) {
                                    showDeleteConfirm = true
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
        /// Centered alert above everything
        .alert(
            "Delete selected emoji\(selectionViewModel.ids.count > 1 ? "s" : "")?",
            isPresented: $showDeleteConfirm
        ) {
            Button("Delete", role: .destructive) {
                onRemoveSelection(selectionViewModel.ids)
                selectionViewModel.clear()
                didDelete.toggle()
                Haptics.success()
            }
            Button("Cancel", role: .cancel) {}
        }
        .withSensoryFeedback(
            selectionTrigger: selectionViewModel.ids.count,
            deleteTrigger: didDelete
        )
        /// All pinches recognized on the document; branch by selection
        .gesture(magnifyGesture)
    }

    // MARK: - Derived pan (persisted + in-flight)

    private var currentPan: CGSize {
        .init(
            width: canvasUI.pan.width + panDragViewOffset.width,
            height: canvasUI.pan.height + panDragViewOffset.height
        )
    }

    private var currentZoom: CGFloat { canvasUI.zoom * pinchScale }

    // MARK: - Gestures

    private var backgroundPanGesture: some Gesture {
        DragGesture()
            .updating($panDragViewOffset) { value, state, _ in
                state = value.translation
            }
            .onEnded { value in
                canvasUI.pan.width += value.translation.width
                canvasUI.pan.height += value.translation.height
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
                    zoom: canvasUI.zoom
                )
                onMoveSelectionBy(selectionViewModel.ids, modelDelta)
            }
    }

    private var magnifyGesture: some Gesture {
        MagnificationGesture()
            .updating($pinchScale) { value, state, _ in
                state = value
            }
            .onEnded { final in
                if selectionViewModel.ids.isEmpty {
                    /// commit document zoom; clamp to sane range
                    let clamped = min(max(canvasUI.zoom * final, 0.25), 8.0)
                    canvasUI.zoom = clamped
                } else {
                    /// commit selection scale to model sizes
                    onScaleSelectionBy(selectionViewModel.ids, final)
                }
            }
    }

}

// MARK: - Sensory Feedback (modern-first with fallback)
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
