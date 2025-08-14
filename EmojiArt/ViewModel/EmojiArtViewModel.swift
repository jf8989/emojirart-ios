// ViewModel/EmojiArtViewModel.swift

import SwiftUI

final class EmojiArtViewModel: ObservableObject {
    @Published private(set) var canvas = EmojiArtCanvas()

    // MARK: - Intent Methods

    func addEmoji(_ text: String, at modelPoint: CGPoint, size: CGFloat = 40) {
        /// Appends an emoji struct to the array for visualization
        canvas.emojiGroup.append(
            .init(
                id: UUID(),
                text: text,
                position: modelPoint,
                size: size
            )
        )
    }

    func remove(_ ids: Set<UUID>) {
        canvas.emojiGroup.removeAll { ids.contains($0.id) }
    }

    func move(_ ids: Set<UUID>, by modelDelta: CGSize) {
        for i in canvas.emojiGroup.indices
        where ids.contains(canvas.emojiGroup[i].id) {
            canvas.emojiGroup[i].position.x += modelDelta.width
            canvas.emojiGroup[i].position.y += modelDelta.height
        }
    }

    func scale(_ ids: Set<UUID>, by factor: CGFloat) {
        for i in canvas.emojiGroup.indices
        where ids.contains(canvas.emojiGroup[i].id) {
            canvas.emojiGroup[i].size = (canvas.emojiGroup[i].size * factor)
                .clamped(to: 30...512)
        }
    }

    // MARK: - Reset

    func resetCanvas() {
        // Clears all emojis from the canvas (does not affect UI-only pan/zoom)
        canvas.emojiGroup.removeAll()
    }
}
