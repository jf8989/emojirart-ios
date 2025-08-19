// View/Components/PaletteChooser.swift

import SwiftUI

/// Horizontal palette selector with emoji previews.
/// Lets user cycle palettes, pick an emoji, add/delete palettes.

struct PaletteChooser: View {
    @EnvironmentObject var store: PaletteStoreViewModel
    let onPick: (String) -> Void

    var body: some View {
        HStack(spacing: 12) {
            Text(store.current.name)
                .font(.headline)
                .padding(.leading, 12)
                .contentShape(Rectangle())
                .onTapGesture { withAnimation(.snappy) { store.next() } }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(Array(store.current.emojis), id: \.self) { ch in
                        Text(String(ch))
                            .font(.system(size: 32))
                            .onTapGesture { onPick(String(ch)) }
                    }
                }
                .padding(.horizontal, 12)
                .id(store.current.id)  // drives the roll transition
            }
            .clipped()
        }
        .frame(height: 60)
        .transition(
            .asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            )
        )
        .animation(.easeInOut(duration: 0.22), value: store.current.id)
        .contextMenu {
            Button {
                withAnimation(.spring(duration: 0.25)) { store.add() }
            } label: {
                Label("Add Palette", systemImage: "plus")
            }

            Button(role: .destructive) {
                withAnimation(.spring(duration: 0.25)) { store.deleteCurrent() }
            } label: {
                Label("Delete Current", systemImage: "trash")
            }
        }
        .padding(.vertical, 4)
    }
}
