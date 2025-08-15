// Extensions/View+DraggableIfSelected.swift

import SwiftUI

public struct DraggableIfSelected: ViewModifier {
    let isSelected: Bool
    let modelZoom: CGFloat
    let selectionIDs: () -> Set<UUID>
    let onMoveSelectionBy: (_ ids: Set<UUID>, _ modelDelta: CGSize) -> Void
    let onDraggingChange: (Bool) -> Void

    @GestureState private var dragOffset: CGSize = .zero

    public func body(content: Content) -> some View {
        content
            .offset(isSelected ? dragOffset : .zero)
            .gesture(
                isSelected
                    ? DragGesture()
                        .updating($dragOffset) { value, state, _ in
                            state = value.translation
                            onDraggingChange(true)
                        }
                        .onEnded { value in
                            let modelDelta = CanvasGeometry.modelDelta(
                                fromViewDelta: value.translation,
                                zoom: max(modelZoom, 0.001)
                            )
                            onMoveSelectionBy(selectionIDs(), modelDelta)
                            onDraggingChange(false)
                        }
                    : nil
            )
    }
}

extension View {
    public func draggableIfSelected(
        isSelected: Bool,
        modelZoom: CGFloat,
        selectionIDs: @escaping () -> Set<UUID>,
        onMoveSelectionBy: @escaping (_ ids: Set<UUID>, _ modelDelta: CGSize) ->
            Void,
        onDraggingChange: @escaping (Bool) -> Void
    ) -> some View {
        modifier(
            DraggableIfSelected(
                isSelected: isSelected,
                modelZoom: modelZoom,
                selectionIDs: selectionIDs,
                onMoveSelectionBy: onMoveSelectionBy,
                onDraggingChange: onDraggingChange
            )
        )
    }
}
