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
    @State private var backgroundColor: Color = .white
    @State var symbolColors: [Color] = [Color.black]
    @State var hierarchyStage: Double = 100
    @State private var isEditing = false
    @State private var showingSharePopover1 = false
    @State private var showingSharePopover2 = false
    @State private var showingSharePopover3 = false
    @State private var showingSharePopover4 = false
    @State private var weight: Font.Weight = .regular

    // MARK: - body
    var body: some View {
        VStack {
            GeometryReader { g in
                VStack {

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

                    HStack {
                        VStack(spacing: 10) {
                            Image(systemName: symbol)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .padding(.all, 10)
                                .symbolRenderingMode(.monochrome)
                                .foregroundColor(symbolColor1)
                                .background(backgroundColor)
                                .font(.system(size: 20, weight: weight))
                            Text("Monochrome")
                                .font(.title3)

                                Button {
                                    showingSharePopover1 = true
                                } label: {
                                    Image(systemName: "square.and.arrow.up")
                                }
                                .popover(isPresented: $showingSharePopover1) {
                                    ShareSymbolView(model: .init(name: symbol,
                                                                 mode: .monochrome,
                                                                 primaryColor: symbolColor1,
                                                                 secondaryColor: symbolColor2,
                                                                 backgroundColor: backgroundColor))
                                }
                        }

                        VStack(spacing: 10) {
                            Image(systemName: symbol)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .padding(.all, 10)
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(symbolColor2, symbolColor1)
                                .background(backgroundColor)
                                .font(.system(size: 20, weight: weight))
                            Text("Palette")
                                .font(.title3)

                                Button {
                                    showingSharePopover2 = true
                                } label: {
                                    Image(systemName: "square.and.arrow.up")
                                }
                                .popover(isPresented: $showingSharePopover2) {
                                    ShareSymbolView(model: .init(name: symbol,
                                                                 mode: .palette,
                                                                 primaryColor: symbolColor1,
                                                                 secondaryColor: symbolColor2,
                                                                 backgroundColor: backgroundColor))
                                }
                        }


                        VStack(spacing: 10) {
                            Image(systemName: symbol)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .padding(.all, 10)
                                .symbolRenderingMode(.hierarchical)
                                .foregroundColor(symbolColor1)
                                .background(backgroundColor)
                                .font(.system(size: 20, weight: weight))
                            Text("Hierarchical")
                                .font(.title3)

                                Button {
                                    showingSharePopover3 = true
                                } label: {
                                    Image(systemName: "square.and.arrow.up")
                                }
                                .popover(isPresented: $showingSharePopover3) {
                                    ShareSymbolView(model: .init(name: symbol,
                                                                 mode: .hierarchical,
                                                                 primaryColor: symbolColor1,
                                                                 secondaryColor: symbolColor2,
                                                                 backgroundColor: backgroundColor))
                                }
                        }

                        VStack(spacing: 10) {
                            Image(systemName: symbol)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .padding(.all, 10)
                                .symbolRenderingMode(.multicolor)
                                .foregroundColor(symbolColor1)
                                .background(backgroundColor)
                                .font(.system(size: 20, weight: weight))
                            Text("Multicolor")
                                .font(.title3)

                                Button {
                                    showingSharePopover4 = true
                                } label: {
                                    Image(systemName: "square.and.arrow.up")
                                }
                                .popover(isPresented: $showingSharePopover4) {
                                    ShareSymbolView(model: .init(name: symbol,
                                                                 mode: .multicolor,
                                                                 primaryColor: symbolColor1,
                                                                 secondaryColor: symbolColor2,
                                                                 backgroundColor: backgroundColor))
                                }
                            }
                    }

                    Spacer()
                        .frame(height: 50)

                    Spacer()
                        .frame(height: 50)


                    HStack {
                        Text("Weight")
                        Spacer()
                        Picker("Weight", selection: $weight) {
                            Text("black".capitalized).fontWeight(.black).tag(Font.Weight.black)
                            Text("heavy".capitalized).fontWeight(.heavy).tag(Font.Weight.heavy)
                            Text("bold".capitalized).fontWeight(.bold).tag(Font.Weight.bold)
                            Text("semibold".capitalized).fontWeight(.semibold).tag(Font.Weight.semibold)
                            Text("regular".capitalized).fontWeight(.regular).tag(Font.Weight.regular)
                            Text("thin".capitalized).fontWeight(.thin).tag(Font.Weight.thin)
                            Text("light".capitalized).fontWeight(.light).tag(Font.Weight.light)
                            Text("ultraLight".capitalized).fontWeight(.ultraLight).tag(Font.Weight.ultraLight)
                        }
                    }

                    ColorPicker("Primary Color", selection: $symbolColor1)

                    ColorPicker("Secondary Color", selection: $symbolColor2)

                    ColorPicker("Background Color", selection: $backgroundColor)
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
