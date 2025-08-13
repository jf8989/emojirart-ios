// View/Components/CanvasView.swift

import SwiftUI

struct CanvasView: View {

    // MARK: - Inputs

    @ObservedObject var selectionViewModel: SelectionViewModel
    let emojis: [Emoji]
    let pan: CGSize
    let zoom: CGFloat

    // MARK: - Body View

    var body: some View {
        emojiInPlaceView
    }

    var emojiInPlaceView: some View {
        GeometryReader { geo in
            ZStack {

                // MARK: - Background Layer

                Color.white.ignoresSafeArea()
                    .contentShape(Rectangle())
                    /// Background tap
                    .onTapGesture {
                        selectionViewModel.clear()
                    }

                // MARK: - Emoji Layer

                /// Only those with a diff get redrawn
                ForEach(emojis) { e in
                    let isSelected = selectionViewModel.contains(e.id)
                    Text(e.text)
                        .font(.system(size: e.size))
                        .padding(2)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(
                                    isSelected ? Color.blue : .clear,
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
