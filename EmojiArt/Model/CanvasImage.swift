// Model/CanvasImage.swift

import CoreGraphics
import Foundation

struct CanvasImage: Identifiable, Hashable {
    let id: UUID
    var data: Data
    var position: CGPoint  // model-space
    var size: CGFloat  // base point size (scaled in view)
}
