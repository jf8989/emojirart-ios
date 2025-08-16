// Models/DroppedImage.swift

import Foundation
import SwiftUI
import UniformTypeIdentifiers

/// Represents an image dropped onto the canvas (drag & drop).
/// Supports importing image data (PNG/JPEG/HEIC, etc.) via Transferable API.

struct DroppedImage: Transferable {
    enum Source { case data(Data) }
    let source: Source

    static var transferRepresentation: some TransferRepresentation {
        // Direct image bytes (PNG/JPEG/HEIC, etc.)
        DataRepresentation(importedContentType: .image) { data in
            DroppedImage(source: .data(data))
        }
    }
}
