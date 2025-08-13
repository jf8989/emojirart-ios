// View/Components/CanvasView.swift

import SwiftUI

struct CanvasView: View {

    // MARK: - Inputs

    @ObservedObject var selectionViewModel: SelectionViewModel
    let emojiGroup: [Emoji]
    let pan: CGSize
    let zoom: CGFloat

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
                    /// Background tap
                    .onTapGesture {
                        selectionViewModel.clear()
                    }

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
                        .position(
                            CanvasGeometry
                                .viewPoint(
                                    fromModel: e.position,
                                    pan: pan,
                                    zoom: zoom,
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
}
