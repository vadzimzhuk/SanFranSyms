//
//  ContentView.swift
//  SanFranSyms
//
//  Created by Vadim Zhuk on 13.06.22.
//

import SwiftUI
import Combine

struct SymbolsListView: View {
    @ObservedObject private var model: ViewModel

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
//        .onChange(of: model.searchText) { oldValue, newValue in
//            model.search(query: newValue)
//        }
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
        private let searchEngine: SFSymbolSemanticSearchEngine = .init()
        var category: SFSymbolsCategory

        var timer: Timer?

        var title: String {
            "\(category.name) (\(symbols.count))"
        }

        var symbols: [String] {

            return searchResult
        }

        var searchResult: [String] = []

        @Published var searchText: String = ""

        private var cancellables: [AnyCancellable] = []

        init(category: SFSymbolsCategory) {
            self.category = category

            $searchText
                .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
                .sink { [weak self] query in
                    self?.search(query: String(query))
                }
                .store(in: &cancellables)

            searchResult = category.sfSymbols.map { $0.id }
        }

        func search(query: String) {
            let nofilter = category.sfSymbols.filter { !query.isEmpty ? $0.id.contains(query.lowercased()) : true }.map { $0.id }

            guard !query.isEmpty else {
                searchResult = nofilter
                return
            }

            searchResult = searchEngine.search(query, in: category.sfSymbols, topK: 100).map { $0.symbol.id }
        }
    }
}
