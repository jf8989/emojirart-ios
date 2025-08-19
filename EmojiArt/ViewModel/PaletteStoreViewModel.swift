// ViewModel/PaletteStoreViewModel.swift
import SwiftUI

/// ObservableObject managing emoji palettes and navigation between them.

final class PaletteStoreViewModel: ObservableObject {
    @Published private(set) var palettes: [Palette]
    @Published private(set) var cursorIndex: Int = 0

    init(
        seed: [Palette] = [
            .init(name: "Faces", emojis: "😀😅🤣😍🤓🥳🤖😴🥶🥺"),
            .init(name: "Animals", emojis: "🐶🐱🐻🐼🦊🦁🐯🐸🐵🦉"),
            .init(name: "Nature", emojis: "🌲🌳🌵🌷🌻🍁🍄🌸🪴🪵"),
            .init(name: "Food", emojis: "🍎🍌🍇🍉🍕🍔🍣🍩🍪🍫"),
            .init(name: "Travel", emojis: "🚗🚌🚎🚲✈️🚀🚢⛵️🛶🏝️"),
            .init(name: "Activities", emojis: "⚽️🏀🎾🏓🎸🎧🎮🎯🧩🛼"),
            .init(name: "Weather", emojis: "☀️🌤️⛅️🌧️🌩️❄️🌪️🌈💨🌫️"),
            .init(name: "Symbols", emojis: "❤️🧡💛💚💙💜🖤🤍⭐️✨"),
            .init(name: "Objects", emojis: "💡📱⌚️💻🖨️📷🔧🔒🔑🧲"),
        ]
    ) {
        palettes = seed.isEmpty ? [.init(name: "Default", emojis: "😀🥳🚀")] : seed
        clampCursor()
    }

    var current: Palette { palettes[cursorIndex] }

    // MARK: - Intents
    func next() { cursorIndex = (cursorIndex + 1) % palettes.count }
    func add(name: String = "New", emojis: String = "🙂😉😎") {
        palettes.insert(
            .init(name: name, emojis: emojis),
            at: min(cursorIndex + 1, palettes.count)
        )
        cursorIndex += 1
        clampCursor()
    }
    func deleteCurrent() {
        guard !palettes.isEmpty else { return }
        palettes.remove(at: cursorIndex)
        if palettes.isEmpty {
            palettes = [.init(name: "Default", emojis: "😀🥳🚀")]
        }
        cursorIndex = min(cursorIndex, palettes.count - 1)
        clampCursor()
    }

    // MARK: - Safety
    private func clampCursor() {
        cursorIndex =
            palettes.isEmpty ? 0 : max(0, min(cursorIndex, palettes.count - 1))
    }
}
