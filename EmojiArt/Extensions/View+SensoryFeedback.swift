// Extensions/View+SensoryFeedback.swift

import SwiftUI

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
