//
//  SymbolDetailsViewL.swift
//  SanFranSyms
//
//  Created by Vadim Zhuk on 14.06.22.
//

import SwiftUI
import UniformTypeIdentifiers

struct SymbolDetailsViewL: View {
    let symbol: String

    ///Properties
    @State var symbolColor1 = Color.black
    @State var symbolColor2 = Color.black
    @State var backgroundColor: Color = .clear
    @State var symbolColors: [Color] = [Color.black]
    @State var hierarchyStage: Double = 100
    @State private var isEditing = false

    // MARK: - body
    var body: some View {
        VStack {
            GeometryReader { g in
                VStack {
                    HStack {
                        VStack {
                            Image(systemName: symbol)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .padding(.all, 10)
                                .symbolRenderingMode(.monochrome)
                                .foregroundColor(symbolColor1)
                                .background(backgroundColor)
                            Text("Monochrome")
                                .font(.title3)
                        }

                        VStack {
                            Image(systemName: symbol)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .padding(.all, 10)
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(symbolColor2, symbolColor1)
                                .background(backgroundColor)
                            Text("Palette")
                                .font(.title3)
                        }


                        VStack {
                            Image(systemName: symbol)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .padding(.all, 10)
                                .symbolRenderingMode(.hierarchical)
                                .foregroundColor(symbolColor1)
                                .background(backgroundColor)
                            Text("Hierarchical")
                                .font(.title3)
                        }

                        VStack {
                            Image(systemName: symbol)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .padding(.all, 10)
                                .symbolRenderingMode(.multicolor)
                                .foregroundColor(symbolColor1)
                                .background(backgroundColor)
                            Text("Multicolor")
                                .font(.title3)
                        }
                    }

                    Spacer()
                        .frame(height: 50)

                    HStack {
                        Text(symbol)
                            .font(.title3)
                            .fontWeight(.bold)
                            .lineLimit(1)
                        Button {
                            UIPasteboard.general.setValue(symbol, forPasteboardType: UTType.plainText.identifier)
                        } label: {
                            Image(systemName: "doc.on.clipboard")
                        }

                    }

                    Spacer()
                        .frame(height: 50)

                    ColorPicker("Main Color", selection: $symbolColor1)

                    ColorPicker("Accessory Color", selection: $symbolColor2)
                }
                .padding(.horizontal, 50)
            }
        }
        .onChange(of: symbolColor1) { newValue in
            print(newValue)
        }
    }

    // MARK: - init

    init(symbol: String) {
        self.symbol = symbol
    }

    // MARK: - methods
}

struct SymbolDetailsViewL_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SymbolDetailsViewL(symbol: "square.and.arrow.up.trianglebadge.exclamationmark")
        }
    }
}
