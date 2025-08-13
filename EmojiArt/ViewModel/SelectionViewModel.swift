// ViewModel/SelectionViewModel.swift

import Foundation

final class SelectionViewModel: ObservableObject {
    @Published var ids = Set<UUID>()
    /// selected emoji ids

    // MARK: - Intents (UI-only)

    func toggle(_ id: UUID) {
        if ids.contains(id) { ids.remove(id) } else { ids.insert(id) }
    }

    func clear() { ids.removeAll() }

    func contains(_ id: UUID) -> Bool { ids.contains(id) }
}
