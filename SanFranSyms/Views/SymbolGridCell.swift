//
//  SymbolGridCell.swift
//  SanFranSyms
//
//  Created by Vadim Zhuk on 14.06.22.
//

import SwiftUI

struct SymbolGridCell: View {
    private(set) var symbolName: String

    init(symbolName: String) {
        self.symbolName = symbolName
    }
    
    var body: some View {
        Image(systemName: symbolName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 30, alignment: .center)
    }
}

struct SymbolGridCell_Previews: PreviewProvider {
    static var previews: some View {
        SymbolGridCell(symbolName: "paperplane")
    }
}
