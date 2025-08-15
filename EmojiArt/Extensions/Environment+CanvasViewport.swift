// Extensions/Environment+CanvasViewport.swift
import SwiftUI

struct CanvasViewportEnv {
    let pan: CGSize
    let zoom: CGFloat
    init(pan: CGSize, zoom: CGFloat) {
        self.pan = pan
        self.zoom = zoom
    }
}

private struct CanvasViewportKey: EnvironmentKey {
    static let defaultValue = CanvasViewportEnv(pan: .zero, zoom: 1)
}

extension EnvironmentValues {
    var canvasViewport: CanvasViewportEnv {
        get { self[CanvasViewportKey.self] }
        set { self[CanvasViewportKey.self] = newValue }
    }
}

extension View {
    /// Injects derived pan/zoom (persisted + live) into the environment.
    func provideCanvasViewport(
        persistedPan: CGSize,
        livePan: CGSize,
        persistedZoom: CGFloat,
        pinchScale: CGFloat
    ) -> some View {
        let combinedPan = CanvasViewportMath.pan(persistedPan, livePan)
        let combinedZoom = CanvasViewportMath.zoom(persistedZoom, pinchScale)
        return environment(
            \.canvasViewport,
            CanvasViewportEnv(pan: combinedPan, zoom: combinedZoom)
        )
    }
}
