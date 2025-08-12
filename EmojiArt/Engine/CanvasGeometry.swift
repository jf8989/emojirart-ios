// Engine/CanvasGeometry.swift

import CoreGraphics

enum CanvasGeometry {
    /// view <-> model transforms given current pan/zoom
    static func viewPoint(
        fromModel p: CGPoint,
        pan: CGSize,
        zoom: CGFloat,
        canvasSize: CGSize
    ) -> CGPoint {
        let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
        let scaled = CGPoint(x: p.x * zoom, y: p.y * zoom)
        return CGPoint(
            x: center.x + pan.width + scaled.x,
            y: center.y + pan.height + scaled.y
        )
    }

    static func modelPoint(
        fromView p: CGPoint,
        pan: CGSize,
        zoom: CGFloat,
        canvasSize: CGSize
    ) -> CGPoint {
        let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
        let translated = CGPoint(
            x: p.x - center.x - pan.width,
            y: p.y - center.y - pan.height
        )
        return CGPoint(x: translated.x / zoom, y: translated.y / zoom)
    }

    static func modelDelta(fromViewDelta d: CGSize, zoom: CGFloat) -> CGSize {
        /// Converts a drag delta in view space to model space
        CGSize(
            width: d.width / zoom,
            height: d.height / zoom
        )
    }
}
