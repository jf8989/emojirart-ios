// Extensions/View+SensoryFeedback.swift

import SwiftUI

/// It adds haptic/sensory feedback for selection and deletion actions.
/// - On iOS 17+: provides selection feedback when selection count changes,
///   and success feedback when a delete is triggered.
/// - On older iOS: falls back to no feedback.

extension View {
    @ViewBuilder
    public func withSensoryFeedback(
        selectionTrigger: Int,
        deleteTrigger: Bool
    ) -> some View {
        if #available(iOS 17.0, *) {
            self
                .sensoryFeedback(.selection, trigger: selectionTrigger)
                .sensoryFeedback(.success, trigger: deleteTrigger)
        } else {
            self
        }
    }
}
