//
//  SymbolsCategoriesView.swift
//  SanFranSyms
//
//  Created by Vadim Zhuk on 14.06.22.
//

import SwiftUI

struct SymbolsCategoriesView: View {
    typealias Category = SymbolsCategory

    let categories: [Category] = {
        let dataProvider: SFSymbolsProvider = SFSymbolsManager()
        let categories = dataProvider.allCategories
        return categories
    }()

    var body: some View {
        NavigationView {
            List {
                ForEach(categories, id: \.self) { category in
                    NavigationLink {
                        SymbolsListView(model: .init(category: category))
                    } label: {
                        Label("\(category.name.localizedCapitalized) (\(category.symbols.count))", systemImage: category.iconName)
                    }
                }
            }
            .listStyle(.sidebar)
            .navigationTitle("Categories")

            SymbolsListView(model: .init(category: categories.first { $0.name == "all" } ?? SymbolsCategory(name: "", iconName: "", symbols: [])))
        }
    }
}

struct SymbolsCategoriesView_Previews: PreviewProvider {
    static var previews: some View {
        SymbolsCategoriesView()
    }
}
