// ViewModel/CanvasUIState.swift

import Foundation
import CoreGraphics

final class CanvasUIState: ObservableObject {
    @Published var pan: CGSize = .zero
    @Published var zoom: CGFloat = 1
}
