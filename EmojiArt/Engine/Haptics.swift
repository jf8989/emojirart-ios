// Engine/Haptics.swift

import UIKit

enum Haptics {
    static func selection() {
        if #available(iOS 17, *) {
            /// SwiftUI sensory feedback
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } else {
            /// UIKit fallback
            UISelectionFeedbackGenerator().selectionChanged()
        }
    }

    static func success() {
        if #available(iOS 17, *) {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        } else {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }
}
