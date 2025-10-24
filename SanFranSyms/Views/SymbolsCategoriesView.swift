//
//  SymbolsCategoriesView.swift
//  SanFranSyms
//
//  Created by Vadim Zhuk on 14.06.22.
//

import SwiftUI
import SwiftData

struct SymbolsCategoriesView: View {
    @EnvironmentObject var contentProvider: SFSymbolsManager

    typealias Category = SFSymbolsCategory

    var categories: [Category] { contentProvider.allCategories }

    @State private var selectedCategory: Category?

    var body: some View {
        NavigationView { //move upper by hierarchy - out of the class
            List(categories, id: \.self, selection: $selectedCategory) { category in
                NavigationLink {
                    SymbolsListView(model: .init(category: category))
                } label: {
                    Label("\(category.name.localizedCapitalized) (\(category.sfSymbols.count))", systemImage: category.iconName)
                }
            }
            .listStyle(.sidebar)
            .navigationTitle("Categories")

            SymbolsListView(model: .init(category: categories.first { $0.name == "all" } ?? SFSymbolsCategory(name: "", iconName: "", sfSymbols: [])))
        }
        .onAppear {
            if let category = categories.first {
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
