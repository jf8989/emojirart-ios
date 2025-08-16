// Model/Palette.swift
import Foundation

/// Represents a palette of emojis with a unique ID, name, and the emoji string.

struct Palette: Identifiable, Hashable {
    let id: UUID
    var name: String
    var emojis: String

    init(id: UUID = UUID(), name: String, emojis: String) {
        self.id = id
        self.name = name
        self.emojis = emojis
    }
}
