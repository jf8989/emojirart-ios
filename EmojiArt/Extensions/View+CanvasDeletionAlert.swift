// Extensions/View+CanvasDeletionAlert.swift

import SwiftUI

/// It provides a reusable alert modifier for confirming deletion of selected items.

extension View {
    func canvasDeletionAlert(
        title: String,
        isPresented: Binding<Bool>,
        onDelete: @escaping () -> Void
    ) -> some View {
        alert(title, isPresented: isPresented) {
            Button("Delete", role: .destructive) { onDelete() }
            Button("Cancel", role: .cancel) {}
        }
    }
}
