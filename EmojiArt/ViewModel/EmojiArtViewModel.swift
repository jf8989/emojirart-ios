// ViewModel/EmojiArtViewModel.swift

import SwiftUI

final class EmojiArtViewModel: ObservableObject {
    // MARK: - Domain
    @Published private(set) var canvas = EmojiArtCanvas()

    // MARK: - UI (transient) + Selection (UI-only), now owned here
    @Published var ui = UIState()
    @Published var selection = Selection()

    // MARK: - UI Sub-Types (kept small; single responsibility)
    struct UIState {
        var pan: CGSize = .zero
        var zoom: CGFloat = 1
        var showDeleteConfirm: Bool = false
        var didDelete: Bool = false
    }
    struct Selection {
        var ids = Set<UUID>()
        mutating func toggle(_ id: UUID) { ids.formSymmetricDifference([id]) }
        mutating func clear() { ids.removeAll() }
        func contains(_ id: UUID) -> Bool { ids.contains(id) }
    }

    // MARK: - Helpers read by views
    func isSelected(_ id: UUID) -> Bool { selection.contains(id) }

    // MARK: - Intent Methods (domain only)
    func addEmoji(_ text: String, at modelPoint: CGPoint, size: CGFloat = 40) {
        canvas.emojiGroup.append(
            .init(id: UUID(), text: text, position: modelPoint, size: size)
        )
    }

    func remove(_ ids: Set<UUID>) {
        canvas.emojiGroup.removeAll { ids.contains($0.id) }
        canvas.images.removeAll { ids.contains($0.id) }
    }

    func move(_ ids: Set<UUID>, by modelDelta: CGSize) {
        for i in canvas.emojiGroup.indices
        where ids.contains(canvas.emojiGroup[i].id) {
            canvas.emojiGroup[i].position.x += modelDelta.width
            canvas.emojiGroup[i].position.y += modelDelta.height
        }
        for i in canvas.images.indices where ids.contains(canvas.images[i].id)
        {
            canvas.images[i].position.x += modelDelta.width
            canvas.images[i].position.y += modelDelta.height
        }
    }

    func scale(_ ids: Set<UUID>, by factor: CGFloat) {
        for i in canvas.emojiGroup.indices
        where ids.contains(canvas.emojiGroup[i].id) {
            canvas.emojiGroup[i].size = (canvas.emojiGroup[i].size * factor)
                .clamped(to: 30...512)
        }
        for i in canvas.images.indices where ids.contains(canvas.images[i].id)
        {
            canvas.images[i].size = (canvas.images[i].size * factor).clamped(
                to: 40...2048
            )
        }
    }

    // MARK: - Image Intents
    func addImage(data: Data, at modelPoint: CGPoint, size: CGFloat = 120) {
        canvas.images.append(
            CanvasImage(
                id: UUID(),
                data: data,
                position: modelPoint,
                size: size.clamped(to: 40...1024)
            )
        )
    }

    func isAcceptableImage(_ data: Data, maxMB: Double = 8) -> Bool {
        Double(data.count) / (1024 * 1024) <= maxMB
    }

    // MARK: - Reset
    func resetCanvas() {
        canvas.emojiGroup.removeAll()
    }
}
