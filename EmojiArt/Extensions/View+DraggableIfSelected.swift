// Extensions/View+DraggableIfSelected.swift

import SwiftUI

public struct DraggableIfSelected: ViewModifier {
    let isSelected: Bool
    let modelZoom: CGFloat
    let selectionIDs: () -> Set<UUID>
    let onMoveSelectionBy: (_ ids: Set<UUID>, _ modelDelta: CGSize) -> Void
    let onDraggingChange: (Bool) -> Void
    @Binding var liveSelectionOffset: CGSize  // shared across all selected

    public func body(content: Content) -> some View {
        content
            .offset(isSelected ? liveSelectionOffset : .zero)
            .gesture(
                isSelected
                    ? DragGesture()
                        .onChanged { value in
                            liveSelectionOffset = value.translation
                            onDraggingChange(true)
                        }
                        .onEnded { value in
                            let modelDelta = CanvasGeometry.modelDelta(
                                fromViewDelta: value.translation,
                                zoom: max(modelZoom, 0.001)
                            )
                            onMoveSelectionBy(selectionIDs(), modelDelta)
                            liveSelectionOffset = .zero
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
        liveSelectionOffset: Binding<CGSize>,  // <-- add this
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
                onDraggingChange: onDraggingChange,
                liveSelectionOffset: liveSelectionOffset
            )
        )
    }
}
