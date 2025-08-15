// Extensions/View+CanvasGestures.swift

import SwiftUI

public struct CanvasGestures: ViewModifier {
    @ObservedObject var vm: EmojiArtViewModel
    @Binding var livePinchScale: CGFloat
    let onScaleSelectionBy: (_ ids: Set<UUID>, _ factor: CGFloat) -> Void

    public func body(content: Content) -> some View {
        content
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        livePinchScale = value
                    }
                    .onEnded { final in
                        if vm.selection.ids.isEmpty {
                            vm.ui.zoom = min(max(vm.ui.zoom * final, 0.25), 8.0)
                        } else {
                            onScaleSelectionBy(vm.selection.ids, final)
                        }
                        livePinchScale = 1
                    }
            )
    }
}

extension View {
    func canvasGestures(
        vm: EmojiArtViewModel,
        livePinchScale: Binding<CGFloat>,
        onScaleSelectionBy: @escaping (_ ids: Set<UUID>, _ factor: CGFloat) ->
            Void
    ) -> some View {
        modifier(
            CanvasGestures(
                vm: vm,
                livePinchScale: livePinchScale,
                onScaleSelectionBy: onScaleSelectionBy
            )
        )
    }
}
