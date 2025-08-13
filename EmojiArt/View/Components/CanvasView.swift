// View/Components/EmojiCanvasView.swift

import SwiftUI

struct CanvasView: View {
    @ObservedObject var selectionViewModel: SelectionViewModel

    let emojis: [Emoji]
    let pan: CGSize
    let zoom: CGFloat

    // MARK: - Body View

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.white.ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectionViewModel.clear()
                    }

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
                        .onTapGesture {
                            selectionViewModel.toggle(e.id)
                        }
                }
            }
        }
    }
}
