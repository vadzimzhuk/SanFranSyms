//
//  SubscriptionExampleView.swift
//  SanFranSyms
//
//  Created by GitHub Copilot on 21.10.25.
//
//  This is an example view showing how to use the SubscriptionService

import SwiftUI

struct SubscriptionExampleView: View {
    @Environment(\.subscriptionService) var subscriptionService
    
    @State private var products: [SubscriptionProduct] = []
    @State private var hasActiveSubscription = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Subscription Example")
                .font(.title)
            
            if hasActiveSubscription {
                Text("✓ Active Subscription")
                    .foregroundColor(.green)
                    .font(.headline)
            } else {
                Text("No Active Subscription")
                    .foregroundColor(.secondary)
            }
            
            if isLoading {
                ProgressView()
            } else {
                List(products) { product in
                    VStack(alignment: .leading) {
                        Text(product.displayName)
                            .font(.headline)
                        Text(product.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(product.displayPrice)
                            .font(.title3)
                            .foregroundColor(.blue)
                        
                        Button("Subscribe") {
                            Task {
                                await purchaseProduct(product)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(.vertical, 8)
                }
            }
            
            Button("Restore Purchases") {
                Task {
                    await restorePurchases()
                }
            }
            .buttonStyle(.bordered)
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
        .padding()
        .task {
            await checkSubscriptionStatus()
            await loadProducts()
        }
    }
    
    private func loadProducts() async {
        guard let service = subscriptionService else {
            errorMessage = "Subscription service not available"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Example product IDs - replace with your actual product IDs
            let productIds = [
                "com.yourapp.monthly",
                "com.yourapp.yearly"
            ]
            products = try await service.fetchProducts(productIds: productIds)
        } catch {
            errorMessage = "Failed to load products: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    private func purchaseProduct(_ product: SubscriptionProduct) async {
        guard let service = subscriptionService else {
            errorMessage = "Subscription service not available"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let success = try await service.purchase(product)
            if success {
                await checkSubscriptionStatus()
            } else {
                errorMessage = "Purchase was cancelled"
            }
        } catch {
            errorMessage = "Purchase failed: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    private func restorePurchases() async {
        guard let service = subscriptionService else {
            errorMessage = "Subscription service not available"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let hasActivePurchase = try await service.restorePurchases()
            if hasActivePurchase {
                await checkSubscriptionStatus()
                errorMessage = "Purchases restored successfully"
            } else {
                errorMessage = "No purchases to restore"
            }
        } catch {
            errorMessage = "Restore failed: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    private func checkSubscriptionStatus() async {
        guard let service = subscriptionService else { return }
        hasActiveSubscription = await service.hasActiveSubscription
    }
}

struct SubscriptionExampleView_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionExampleView()
    }
}
