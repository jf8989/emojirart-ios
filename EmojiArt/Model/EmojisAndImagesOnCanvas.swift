// Model/EmojiArtCanvas.swift

import Foundation

/// Represents the canvas model, containing all emojis and images
/// currently placed on the canvas.

struct EmojisAndImagesOnCanvas {
    var emojisOnCanvas: [Emoji] = []
    var images: [CanvasImage] = []
}
