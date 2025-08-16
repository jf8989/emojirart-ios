// Extensions/View+CanvasDrops.swift

import SwiftUI

/// It provides a reusable modifier to handle drop targets for images and URLs on the canvas.

extension View {
    func canvasDrops(
        vm: EmojiArtViewModel,
        canvasSize: CGSize,
        viewport: CanvasViewportEnv
    ) -> some View {
        dropDestination(for: DroppedImage.self) { items, location in
            let modelPoint = CanvasGeometry.modelPoint(
                fromView: location,
                pan: viewport.pan,
                zoom: viewport.zoom,
                canvasSize: canvasSize
            )
            let initialSize: CGFloat = (120 / max(viewport.zoom, 0.001))
                .clamped(to: 40...512)
            for item in items {
                if case .data(let data) = item.source,
                    vm.isAcceptableImage(data)
                {
                    vm.addImage(data: data, at: modelPoint, size: initialSize)
                }
            }
            return true
        }
        .dropDestination(for: URL.self) { urls, location in
            let modelPoint = CanvasGeometry.modelPoint(
                fromView: location,
                pan: viewport.pan,
                zoom: viewport.zoom,
                canvasSize: canvasSize
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
                        if let (data, _) = try? await URLSession.shared.data(
                            from: url
                        ),
                            vm.isAcceptableImage(data)
                        {
                            await MainActor.run {
                                vm.addImage(
                                    data: data,
                                    at: modelPoint,
                                    size: initialSize
                                )
                            }
                        }
                    }
                }
            }
            return true
        }
    }
}
