// Extensions/View+SelectionInteractions.swift

import SwiftUI

public struct SelectionInteractions: ViewModifier {
    let isSelected: Bool
    let onSelect: () -> Void
    let onRequestDelete: () -> Void

    public func body(content: Content) -> some View {
        content
            .onTapGesture { onSelect() }
            .onTapGesture(count: 2) {
                if isSelected { onRequestDelete() }
            }
            .contextMenu {
                if isSelected {
                    Button(role: .destructive) {
                        onRequestDelete()
                    } label: {
                        Label("Delete Selected", systemImage: "trash")
                    }
                }
            }
    }
}

extension View {
    public func selectionInteractions(
        isSelected: Bool,
        onSelect: @escaping () -> Void,
        onRequestDelete: @escaping () -> Void
    ) -> some View {
        modifier(
            SelectionInteractions(
                isSelected: isSelected,
                onSelect: onSelect,
                onRequestDelete: onRequestDelete
            )
        )
    }
}
