//
//  SubscriptionProduct.swift
//  SanFranSyms
//
//  Created by GitHub Copilot on 21.10.25.
//

import Foundation
import StoreKit

struct SubscriptionProduct: Identifiable, Hashable {
    let id: String
    let displayName: String
    let description: String
    let price: Decimal
    let displayPrice: String
    
    init(id: String, displayName: String, description: String, price: Decimal, displayPrice: String) {
        self.id = id
        self.displayName = displayName
        self.description = description
        self.price = price
        self.displayPrice = displayPrice
    }
    
    @available(iOS 15.0, *)
    init(from product: Product) {
        self.id = product.id
        self.displayName = product.displayName
        self.description = product.description
        self.price = product.price
        self.displayPrice = product.displayPrice
    }
}
