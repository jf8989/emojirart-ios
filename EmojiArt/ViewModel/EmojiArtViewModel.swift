// ViewModel/EmojiArtViewModel.swift

import SwiftUI

final class EmojiArtViewModel: ObservableObject {
    @Published private(set) var canvas = EmojiArtCanvas()

    // MARK: - Intent Methods

    func addEmoji(_ text: String, at modelPoint: CGPoint, size: CGFloat = 40) {
        canvas.emojis.append(
            .init(
                id: UUID(),
                text: text,
                position: modelPoint,
                size: size
            )
        )
    }

    func remove(_ ids: Set<UUID>) {
        canvas.emojis.removeAll { ids.contains($0.id) }
    }

    func move(_ ids: Set<UUID>, by modelDelta: CGSize) {
        for i in canvas.emojis.indices where ids.contains(canvas.emojis[i].id) {
            canvas.emojis[i].position.x += modelDelta.width
            canvas.emojis[i].position.y += modelDelta.height
        }
    }

    func scale(_ ids: Set<UUID>, by factor: CGFloat) {
        for i in canvas.emojis.indices where ids.contains(canvas.emojis[i].id) {
            canvas.emojis[i].size *= factor
        }
    }

}
