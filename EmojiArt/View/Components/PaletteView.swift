// View/Components/PaletteView.swift

import SwiftUI

struct PaletteView: View {
    let palette = "😀😅🥳🤖🐶🐱🌟🔥🍎🍕🚀🏠🌲🚗🛶"
    let onPick: (String) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(Array(palette), id: \.self) { ch in
                    Text(String(ch)).font(.system(size: 32))
                        .onTapGesture {
                            onPick(String(ch))
                        }
                }
            }
            .padding(.horizontal)
        }
        .frame(height: 56)
    }

}
