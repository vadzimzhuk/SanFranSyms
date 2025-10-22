//
//  ContentView.swift
//  SanFranSyms
//
//  Created by Vadim Zhuk on 13.06.22.
//

import SwiftUI


struct SymbolsListView: View {
    @ObservedObject private var model: ViewModel

    @State private var showingPopover: Bool = false

    private var title: String {
        "SFSymbols"
    }

    private var symbolNames: [String] {
        model.searchResult
    }

    private var threeColumnsGridStyle: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack(spacing: 20) {
            TextField("Search text field", text: $model.searchText, prompt: Text("Type symbol name here"))

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
        SymbolsListView(model: .init(category: SFSymbolsCategory(name: "", iconName: "", sfSymbols: [])))
    }
}

extension SymbolsListView {

    class ViewModel: ObservableObject {

        var category: SFSymbolsCategoryProtocol
        private var searchDelayTimer: Timer?

        var title: String {
            "\(category.name) (\(symbols.count))"
        }

        var symbols: [String] {
            category.symbols.filter { !searchText.isEmpty ? $0.contains(searchText.lowercased()) : true }
        }

        @Published var semanticSearhIsOn: Bool = true
        var semanticSearchAvailable: Bool

//        @Published
        var searchText: String = "" {
            didSet {
                if semanticSearhIsOn {
                    if !searchText.isEmpty {
                        scheduleSearch(text: searchText)
                    } else {
                        searchDelayTimer?.invalidate()
                        searchResult = category.symbols
                    }
                } else {
                    searchResult = category.sfSymbols.map { $0.id }.filter { $0.contains(searchText) }
                }
            }
        }

        @Published var searchResult: [String]

        init(category: SFSymbolsCategoryProtocol) {
            self.category = category
            self.searchResult = category.symbols
            self.semanticSearchAvailable = category.sfSymbols.first?.token.isEmpty == false
            self.semanticSearhIsOn = semanticSearchAvailable
        }

        func scheduleSearch(text: String) {
            searchDelayTimer?.invalidate()
            searchDelayTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
                self?.search(text: text)
            }
        }

        func search(text: String) {
            let result = SFSymbolSemanticSearchEngine.shared.search(text, in: category.sfSymbols, topK: 100).map { ($0.symbol.id, $0.score) }.filter { $0.1 > 0.3 }
            searchResult = result.map { $0.0 }

            print("Search term: \(text)")
            print("Result:")

            for item in result {
                print("\(item.0): \(item.1)")
            }
        }
    }
}

protocol SFSymbolsCategoryProtocol {
    var name: String { get }
    var symbols: [String] { get }
    var sfSymbols: [SFSymbol] { get }
}
