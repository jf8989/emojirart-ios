// Extensions/View+SelectionInteractions.swift

import SwiftUI

/// It adds tap, double-tap, and context menu interactions for selection.
/// - Single tap: toggles selection.
/// - Double tap: deletes if selected.
/// - Context menu: provides a delete option if selected.

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
