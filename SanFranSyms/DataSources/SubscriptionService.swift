//
//  SubscriptionService.swift
//  SanFranSyms
//
//  Created by GitHub Copilot on 21.10.25.
//

import Foundation
import StoreKit

enum SubscriptionError: Error {
    case failedVerification
    case productNotFound
    case purchaseFailed
    case unknown
}

protocol SubscriptionService {
    var products: [SubscriptionProduct] { get async throws }
    var hasActiveSubscription: Bool { get async }
    
    func fetchProducts(productIds: [String]) async throws -> [SubscriptionProduct]
    func purchase(_ product: SubscriptionProduct) async throws -> Bool
    func restorePurchases() async throws -> Bool
}

@available(iOS 15.0, *)
class SubscriptionManager: SubscriptionService {
    
    private var loadedProducts: [Product] = []
    private var updateListenerTask: Task<Void, Error>?
    
    init() {
        updateListenerTask = listenForTransactions()
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    var products: [SubscriptionProduct] {
        get async throws {
            loadedProducts.map { SubscriptionProduct(from: $0) }
        }
    }
    
    var hasActiveSubscription: Bool {
        get async {
            for await result in Transaction.currentEntitlements {
                guard case .verified(let transaction) = result else {
                    continue
                }
                
                if transaction.productType == .autoRenewable && !transaction.isUpgraded {
                    return true
                }
            }
            
            return false
        }
    }
    
    func fetchProducts(productIds: [String]) async throws -> [SubscriptionProduct] {
        loadedProducts = try await Product.products(for: productIds)
        return loadedProducts.map { SubscriptionProduct(from: $0) }
    }
    
    func purchase(_ product: SubscriptionProduct) async throws -> Bool {
        guard let storeProduct = loadedProducts.first(where: { $0.id == product.id }) else {
            throw SubscriptionError.productNotFound
        }
        
        let result = try await storeProduct.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            return true
            
        case .userCancelled:
            return false
            
        case .pending:
            return false
            
        @unknown default:
            return false
        }
    }
    
    func restorePurchases() async throws -> Bool {
        try await AppStore.sync()
        
        var hasActivePurchase = false
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else {
                continue
            }
            
            if transaction.productType == .autoRenewable && !transaction.isUpgraded {
                hasActivePurchase = true
            }
        }
        
        return hasActivePurchase
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw SubscriptionError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                guard case .verified(let transaction) = result else {
                    continue
                }
                
                await transaction.finish()
            }
        }
    }
}
