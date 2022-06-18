//
//  SymbolDetailsView.swift
//  SanFranSyms
//
//  Created by Vadim Zhuk on 14.06.22.
//

import SwiftUI
import UniformTypeIdentifiers

struct SymbolDetailsView: View {
    let symbol: String

    ///Properties
    @State var mode: AppSymbolRenderingMode = .monochrome
    @State var symbolColor1 = Color.black
    @State var symbolColor2 = Color.black
    @State var backgroundColor: Color = .clear
    @State var symbolColors: [Color] = [Color.black]
//    @State var hierarchyStage: Double = 100
//    @State private var isEditing = false
    @State private var showingSharePopover = false

    // MARK: - body
    var body: some View {
        VStack {
            GeometryReader { g in
                VStack {
                    // TODO: - fix to avoid duplication
                    if mode != .palette {
                        Image(systemName: symbol)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(.all, 100)
                            .symbolRenderingMode(mode.systemMode)
                            .foregroundColor(symbolColor1)
                            .background(backgroundColor)
                    } else {
                        Image(systemName: symbol)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(.all, 100)
                            .symbolRenderingMode(mode.systemMode)
                            .foregroundStyle(symbolColor2, symbolColor1)
                            .background(backgroundColor)
                    }

                    HStack {
                        Text(symbol)
                            .font(.title3)
                            .fontWeight(.bold)
                            .lineLimit(1)
                        Button {
                            UIPasteboard.general.string = symbol
                        } label: {
                            Image(systemName: "doc.on.clipboard")
                        }

                        Button {
                            showingSharePopover = true
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                        }
                        .popover(isPresented: $showingSharePopover) {
                            ShareSymbolView(model: .init(name: symbol,
                                                         mode: mode,
                                                         primaryColor: symbolColor1,
                                                         secondaryColor: symbolColor2))
                        }
                    }

                    Picker("Rendering mode", selection: $mode) {
                        Text(AppSymbolRenderingMode.monochrome.rawValue.capitalized).tag(AppSymbolRenderingMode.monochrome)
                        Text(AppSymbolRenderingMode.multicolor.rawValue.capitalized).tag(AppSymbolRenderingMode.multicolor)
                        Text(AppSymbolRenderingMode.palette.rawValue.capitalized).tag(AppSymbolRenderingMode.palette)
                        Text(AppSymbolRenderingMode.hierarchical.rawValue.capitalized).tag(AppSymbolRenderingMode.hierarchical)
                    }

                    ColorPicker("Primary Color", selection: $symbolColor1)

                    if mode == .palette {
                        ColorPicker("Secondary Color", selection: $symbolColor2)
                    }
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

struct SymbolDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SymbolDetailsView(symbol: "square.and.arrow.up.trianglebadge.exclamationmark")
        }
    }
}

enum AppSymbolRenderingMode: String, CaseIterable, Identifiable {
    case monochrome, multicolor, palette, hierarchical
    
    var id: Self { self }

    var systemMode: SymbolRenderingMode {
        switch self {
            case .multicolor: return .multicolor
            case .palette: return .palette
            case .monochrome: return .monochrome
            case .hierarchical: return .hierarchical
        }
    }
}
