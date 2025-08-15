// View/Components/ImageNodeView.swift

import SwiftUI
import UIKit

struct ImageNodeView: View {
    @ObservedObject var vm: EmojiArtViewModel
    let item: CanvasImage
    let canvasSize: CGSize

    @Environment(\.canvasViewport) private var viewport

    var body: some View {
        // Match emoji behavior: document zoom when no selection; freeze at persisted zoom when there is a selection
        let docScale = vm.selection.ids.isEmpty ? viewport.zoom : vm.ui.zoom

        // Note: we keep base size = item.size and apply zoom via scaleEffect (same as emojis)
        if let uiImage = UIImage(data: item.data) {
            Image(uiImage: uiImage)
                .resizable()
                .interpolation(.medium)
                .scaledToFit()
                .frame(width: item.size, height: item.size)
                .scaleEffect(docScale)
                .position(
                    CanvasGeometry.viewPoint(
                        fromModel: item.position,
                        pan: viewport.pan,
                        zoom: docScale,
                        canvasSize: canvasSize
                    )
                )
        }
    }
}
