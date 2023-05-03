//
//  SymbolsCategoriesView.swift
//  SanFranSyms
//
//  Created by Vadim Zhuk on 14.06.22.
//

import SwiftUI

struct SymbolsCategoriesView: View {
    @Environment(\.contentProvider) var contentProvider

    typealias Category = SymbolsCategory

    var categories: [Category] { contentProvider.allCategories }

    @State private var selectedCategory: Category?

    var body: some View {
        NavigationView { //move upper by hierarchy - out of this class
            List(categories, id: \.self, selection: $selectedCategory) { category in
                NavigationLink {
                    SymbolsListView(model: .init(category: category))
                } label: {
                    Label("\(category.name.localizedCapitalized) (\(category.symbols.count))", systemImage: category.iconName)
                }
            }
//            List (selection: $selectedCategory) {
//                ForEach(categories, id: \.self) { category in
//                    NavigationLink {
//                        SymbolsListView(model: .init(category: category))
//                    } label: {
//                        Label("\(category.name.localizedCapitalized) (\(category.symbols.count))", systemImage: category.iconName)
//                    }
//                }
//            }
            .listStyle(.sidebar)
            .navigationTitle("Categories")

            SymbolsListView(model: .init(category: categories.first { $0.name == "all" } ?? SymbolsCategory(name: "", iconName: "", symbols: [])))
        }
    }

    init(/*categories: [Category],*/selectedCategory: Category? = nil) {
//        self.categories = categories
        
        guard categories.count > 1 else { return }

        self.selectedCategory = selectedCategory ?? categories[1]
    }
}

struct SymbolsCategoriesView_Previews: PreviewProvider {
    static var previews: some View {
        SymbolsCategoriesView()
    }
}
