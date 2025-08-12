// View/EmojiArtMainView.swift

import SwiftUI

struct EmojiArtMainView: View {
    @StateObject private var viewModel = EmojiArtViewModel()

    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geo in
                ZStack {
                    Color.white.ignoresSafeArea()
                    ForEach(viewModel.canvas.emojis) { e in
                        Text(e.text).font(.system(size: e.size))
                            .position(
                                CanvasGeometry
                                    .viewPoint(
                                        fromModel: e.position,
                                        pan: .zero,
                                        zoom: 1,
                                        canvasSize: geo.size
                                    )
                            )
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
