// Extensions/CanvasViewport.swift

import CoreGraphics

enum CanvasViewportMath {
    static func pan(_ persisted: CGSize, _ live: CGSize) -> CGSize {
        .init(
            width: persisted.width + live.width,
            height: persisted.height + live.height
        )
    }

    static func zoom(_ persisted: CGFloat, _ liveScale: CGFloat) -> CGFloat {
        persisted * liveScale
    }
}
