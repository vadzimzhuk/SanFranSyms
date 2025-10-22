//
//  SymbolsCategoriesView.swift
//  SanFranSyms
//
//  Created by Vadim Zhuk on 14.06.22.
//

import SwiftUI

struct SymbolsCategoriesView: View {
    @Environment(\.contentProvider) var contentProvider

    typealias Category = SFSymbolsCategory

//    var categories: [Category] { contentProvider.allCategories }
    var sfSymbolsCategories: [Category] { contentProvider.sfSymbolsCategories }

    @State private var selectedCategory: Category?

    var body: some View {
        NavigationView { //move upper by hierarchy - out of the class
            List(sfSymbolsCategories, id: \.self, selection: $selectedCategory) { category in
                NavigationLink {
                    SymbolsListView(model: .init(category: category))
                } label: {
                    Label("\(category.name.localizedCapitalized) (\(category.symbols.count))", systemImage: category.iconName)
                }
            }
            .listStyle(.sidebar)
            .navigationTitle("Categories")

            SymbolsListView(model: .init(category: sfSymbolsCategories.first { $0.name == "all" } ?? SFSymbolsCategory(name: "", iconName: "", sfSymbols: [])))
        }
        .onAppear {
            if let category = sfSymbolsCategories.first {
                selectedCategory = category
            }
        }
    }

    init(selectedCategory: Category? = nil) {
        
//        guard categories.count > 1 else { return }


    }
}

struct SymbolsCategoriesView_Previews: PreviewProvider {
    static var previews: some View {
        SymbolsCategoriesView()
    }
}
