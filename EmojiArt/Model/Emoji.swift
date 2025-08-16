// Model/Emoji.swift

import Foundation
import CoreGraphics

/// Represents an emoji placed on the canvas, including its identity,
/// text content, position in model-space, and base font size.

struct Emoji: Identifiable, Hashable {
    let id: UUID
    var text: String
    var position: CGPoint  /// model-space; origin = canvas center
    var size: CGFloat      /// base font size in points
}
