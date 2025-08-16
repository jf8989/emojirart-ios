// Model/CanvasImage.swift

import CoreGraphics
import Foundation

/// Represents an image placed on the canvas with its model-space properties.
/// Stores the unique ID, binary data for the image, its position, and its base size.

struct CanvasImage: Identifiable, Hashable {
    let id: UUID
    var data: Data
    var position: CGPoint  // model-space
    var size: CGFloat  // base point size (scaled in view)
}
