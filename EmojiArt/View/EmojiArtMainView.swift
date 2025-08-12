// View/EmojiArtMainView.swift

import SwiftUI

struct EmojiArtMainView: View {
    @StateObject private var viewModel = EmojiArtViewModel()
    @State private var selection = Set<UUID>()

    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geo in
                ZStack {
                    Color.white.ignoresSafeArea()
                        .contentShape(Rectangle())
                        .onTapGesture { selection.removeAll() }

                    ForEach(viewModel.canvas.emojis) { e in
                        let isSelected = selection.contains(e.id)
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
                                        pan: .zero,
                                        zoom: 1,
                                        canvasSize: geo.size
                                    )
                            )
                            .onTapGesture {
                                if isSelected {
                                    selection.remove(e.id)
                                } else {
                                    selection.insert(e.id)
                                }
                            }
                    }
                }
            }
            Divider()
            PaletteView { picked in
                viewModel.addEmoji(picked, at: .zero)/// center
            }
        }
    }
}

#Preview {
    EmojiArtMainView()
}
