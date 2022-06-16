//
//  ContentView.swift
//  SanFranSyms
//
//  Created by Vadim Zhuk on 13.06.22.
//

import SwiftUI


struct SymbolsListView: View {
    private var model: ViewModel

    private var idiom : UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }

    @State private var showingPopover: Bool = false

    private var title: String {
        "SFSymbols"
    }

    private var symbolNames: [String] {
        model.symbols
    }

    private var threeColumnsGridStyle: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack {
            ScrollView {
                LazyVGrid(columns: threeColumnsGridStyle, spacing: 30){
                    ForEach(symbolNames, id: \.self) { symbol in
                        NavigationLink {
                            if idiom == .pad {
                                SymbolDetailsViewL(symbol: symbol)
                            } else {
                                SymbolDetailsView(symbol: symbol)
                            }
                        } label: {
                            SymbolGridCell(symbolName: symbol)
                        }
                    }
                }
            }
        }
        .padding(.all, 20)
        .navigationTitle(model.title.localizedCapitalized)
    }

    init(model: ViewModel) {
        self.model = model
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SymbolsListView(model: .init(category: SymbolsCategory(name: "", iconName: "", symbols: [])))
    }
}

extension SymbolsListView {

    class ViewModel {
        var category: SymbolsCategory

        var title: String {
            "\(category.name) (\(symbols.count))"
        }

        var symbols: [String] {
            category.symbols
        }

        init(category: SymbolsCategory) {
            self.category = category
        }
    }
}
