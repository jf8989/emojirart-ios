// ViewModel/EmojiArtViewModel.swift

import SwiftUI
import UIKit

/// ObservableObject managing domain (canvas), UI state, and selection.

final class EmojiArtViewModel: ObservableObject {
    // MARK: - Domain
    @Published private(set) var elementsOnCanvas = EmojisAndImagesOnCanvas()

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
        elementsOnCanvas.emojisOnCanvas.append(
            .init(id: UUID(), text: text, position: modelPoint, size: size)
        )
    }

    func remove(_ ids: Set<UUID>) {
        elementsOnCanvas.emojisOnCanvas.removeAll { ids.contains($0.id) }
        elementsOnCanvas.images.removeAll { ids.contains($0.id) }
    }

    func move(_ ids: Set<UUID>, by modelDelta: CGSize) {
        for i in elementsOnCanvas.emojisOnCanvas.indices
        where ids.contains(elementsOnCanvas.emojisOnCanvas[i].id) {
            elementsOnCanvas.emojisOnCanvas[i].position.x += modelDelta.width
            elementsOnCanvas.emojisOnCanvas[i].position.y += modelDelta.height
        }
        for i in elementsOnCanvas.images.indices where ids.contains(elementsOnCanvas.images[i].id) {
            elementsOnCanvas.images[i].position.x += modelDelta.width
            elementsOnCanvas.images[i].position.y += modelDelta.height
        }
    }

    func scale(_ ids: Set<UUID>, by factor: CGFloat) {
        for i in elementsOnCanvas.emojisOnCanvas.indices
        where ids.contains(elementsOnCanvas.emojisOnCanvas[i].id) {
            elementsOnCanvas.emojisOnCanvas[i].size = (elementsOnCanvas.emojisOnCanvas[i].size * factor)
                .clamped(to: 30...512)
        }
        for i in elementsOnCanvas.images.indices where ids.contains(elementsOnCanvas.images[i].id) {
            elementsOnCanvas.images[i].size = (elementsOnCanvas.images[i].size * factor).clamped(
                to: 40...2048
            )
        }
    }

    // MARK: - Image Intents
    func addImage(data: Data, at modelPoint: CGPoint, size: CGFloat = 120) {
        elementsOnCanvas.images.append(
            CanvasImage(
                id: UUID(),
                data: data,
                position: modelPoint,
                size: size.clamped(to: 40...1024)
            )
        )
    }

    func isAcceptableImage(_ data: Data, maxMB: Double = 8) -> Bool {
        guard Double(data.count) / (1024 * 1024) <= maxMB else { return false }
        return UIImage(data: data) != nil
    }

    // MARK: - Reset
    func resetCanvas() {
        elementsOnCanvas.emojisOnCanvas.removeAll()
        elementsOnCanvas.images.removeAll()
    }
}
