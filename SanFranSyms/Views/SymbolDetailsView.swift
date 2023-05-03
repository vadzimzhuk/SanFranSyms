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
    @State var backgroundColor: Color = .white
    @State var symbolColors: [Color] = [Color.black]
    @State var weight: Font.Weight = .regular
    @State private var showingSharePopover = false

    // MARK: - body
    var body: some View {
        VStack {
            GeometryReader { g in
                VStack {
                    Spacer()
                        .frame(height: 10)
                    // TODO: - fix to avoid duplication
                    if mode != .palette {
                        Image(systemName: symbol)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(.all, 100)
                            .symbolRenderingMode(mode.systemMode)
                            .foregroundColor(symbolColor1)
                            .background(backgroundColor)
                            .font(.system(size: 20, weight: weight))
                    } else {
                        Image(systemName: symbol)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(.all, 100)
                            .symbolRenderingMode(mode.systemMode)
                            .foregroundStyle(symbolColor2, symbolColor1)
                            .background(backgroundColor)
                            .font(.system(size: 20, weight: weight))
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
                                                         secondaryColor: symbolColor2,
                                                         backgroundColor: backgroundColor))
                        }
                    }

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

                    HStack {
                        Text("Mode")
                        Spacer()
                        Picker("Rendering mode", selection: $mode) {
                            Text(AppSymbolRenderingMode.monochrome.rawValue.capitalized).tag(AppSymbolRenderingMode.monochrome)
                            Text(AppSymbolRenderingMode.multicolor.rawValue.capitalized).tag(AppSymbolRenderingMode.multicolor)
                            Text(AppSymbolRenderingMode.palette.rawValue.capitalized).tag(AppSymbolRenderingMode.palette)
                            Text(AppSymbolRenderingMode.hierarchical.rawValue.capitalized).tag(AppSymbolRenderingMode.hierarchical)
                        }
                    }

                    ColorPicker("Primary Color", selection: $symbolColor1)

                    if mode == .palette {
                        ColorPicker("Secondary Color", selection: $symbolColor2)
                    }

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

    var uiKitCode: String {
        switch self {
            case .palette:
                return "UIImage(systemName: \"%1$@\")!.applyingSymbolConfiguration(UIImage.SymbolConfiguration(paletteColors: [UIColor(cgColor: %2$@), UIColor(cgColor: %3$@)]))!"
            case .multicolor:
                return "UIImage(systemName: \"%1$@\")!.applyingSymbolConfiguration(UIImage.SymbolConfiguration(hierarchicalColor: UIColor(cgColor: %3$@)))!"
            case .hierarchical:
                return "UIImage(systemName: \"%1$@\")!.applyingSymbolConfiguration(UIImage.SymbolConfiguration(hierarchicalColor: UIColor(cgColor: %3$@)))!"
            case .monochrome:
                return "UIImage(systemName: \"%1$@\")!.applyingSymbolConfiguration(UIImage.SymbolConfiguration(hierarchicalColor: UIColor(cgColor: %3$@))!"
        }
    }

    var swiftUICode: String {
        switch self {
            case .palette:
                return """
Image(systemName: \"%1$@\")
.symbolRenderingMode(.%2$@)
.foregroundColor(Color(cgColor: %3$@)))
"""
            default:
                return """
Image(systemName: \"%1$@\")
.symbolRenderingMode(.%2$@)
.foregroundStyle(Color(cgColor: %3$@), Color(cgColor: %4$@))
"""
        }
    }
}
