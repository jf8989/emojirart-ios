// View/Components/CanvasView.swift

import SwiftUI

struct CanvasView: View {

    // MARK: - Inputs

    @ObservedObject var selectionViewModel: SelectionViewModel
    @ObservedObject var canvasUI: CanvasUIState
    let emojiGroup: [Emoji]
    let onMoveSelectionBy: (_ ids: Set<UUID>, _ modelDelta: CGSize) -> Void

    // MARK: - Gesture State

    @GestureState private var panDragViewOffset: CGSize = .zero
    /// view-space delta during background pan
    @GestureState private var emojiDragViewOffset: CGSize = .zero
    /// view-space delta during emoji drag

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
                    Text(e.text)
                        .font(.system(size: e.size))
                        .padding(2)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(
                                    showSelectionChrome ? Color.blue : .clear,
                                    lineWidth: 2
                                )
                        )
                        /// live offset while dragging selection
                        .offset(
                            showSelectionChrome ? emojiDragViewOffset : .zero
                        )
                        .position(
                            CanvasGeometry
                                .viewPoint(
                                    fromModel: e.position,
                                    pan: currentPan,
                                    zoom: canvasUI.zoom,
                                    canvasSize: geo.size
                                )
                        )
                        /// Emoji tap
                        .onTapGesture {
                            selectionViewModel.toggle(e.id)
                        }
                }
            }
        }
    }

    // MARK: - Derived pan (persisted + in-flight)

    private var currentPan: CGSize {
        .init(
            width: canvasUI.pan.width + panDragViewOffset.width,
            height: canvasUI.pan.height + panDragViewOffset.height
        )
    }

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

}
