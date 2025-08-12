// Model/Emoji.swift

import Foundation
import CoreGraphics

struct Emoji: Identifiable, Hashable {
    let id: UUID
    var text: String
    var position: CGPoint  /// model-space; origin = canvas center
    var size: CGFloat      /// base font size in points
}
