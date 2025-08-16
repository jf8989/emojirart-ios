// Extensions/View+SelectionChrome.swift

import SwiftUI

/// It adds a visual outline ("chrome") around selected items.
/// The outline shows when an item is selected and not being interacted with (e.g., not dragged or pinched).

// MARK: - Adds the selection outline and z-order without changing behavior.
public struct SelectionChrome: ViewModifier {
    let isSelected: Bool
    let isInteracting: Bool
    let cornerRadius: CGFloat
    let lineWidth: CGFloat

    public func body(content: Content) -> some View {
        content
            .padding(2)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        isSelected ? Color.blue : .clear,
                        lineWidth: lineWidth
                    )
                    .opacity(isSelected && !isInteracting ? 1 : 0)
                    .zIndex(isSelected ? 1 : 0)
                    .animation(nil, value: isInteracting)
            )
    }
}

extension View {
    public func selectionChrome(
        isSelected: Bool,
        isInteracting: Bool,
        cornerRadius: CGFloat = 4,
        lineWidth: CGFloat = 2
    ) -> some View {
        modifier(
            SelectionChrome(
                isSelected: isSelected,
                isInteracting: isInteracting,
                cornerRadius: cornerRadius,
                lineWidth: lineWidth
            )
        )
    }
}
