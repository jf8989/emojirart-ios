// Models/DroppedImage.swift

import Foundation
import SwiftUI
import UniformTypeIdentifiers

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
