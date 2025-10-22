//
//  SubscriptionServiceTests.swift
//  SanFranSymsTests
//
//  Created by GitHub Copilot on 21.10.25.
//

import XCTest
@testable import SanFranSyms

class MockSubscriptionService: SubscriptionService {
    var mockProducts: [SubscriptionProduct] = []
    var mockHasActiveSubscription: Bool = false
    var shouldThrowError: Bool = false
    
    var products: [SubscriptionProduct] {
        get async throws {
            if shouldThrowError {
                throw SubscriptionError.unknown
            }
            return mockProducts
        }
    }
    
    var hasActiveSubscription: Bool {
        get async {
            return mockHasActiveSubscription
        }
    }
    
    func fetchProducts(productIds: [String]) async throws -> [SubscriptionProduct] {
        if shouldThrowError {
            throw SubscriptionError.unknown
        }
        
        mockProducts = productIds.map { id in
            SubscriptionProduct(
                id: id,
                displayName: "Test Product \(id)",
                description: "Test Description",
                price: 9.99,
                displayPrice: "$9.99"
            )
        }
        return mockProducts
    }
    
    func purchase(_ product: SubscriptionProduct) async throws -> Bool {
        if shouldThrowError {
            throw SubscriptionError.purchaseFailed
        }
        
        mockHasActiveSubscription = true
        return true
    }
    
    func restorePurchases() async throws -> Bool {
        if shouldThrowError {
            throw SubscriptionError.unknown
        }
        
        return mockHasActiveSubscription
    }
}

class SubscriptionServiceTests: XCTestCase {
    
    var subscriptionService: MockSubscriptionService!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        subscriptionService = MockSubscriptionService()
    }
    
    override func tearDownWithError() throws {
        subscriptionService = nil
        try super.tearDownWithError()
    }
    
    func testFetchProducts() async throws {
        let productIds = ["com.test.monthly", "com.test.yearly"]
        let products = try await subscriptionService.fetchProducts(productIds: productIds)
        
        XCTAssertEqual(products.count, 2)
        XCTAssertEqual(products[0].id, "com.test.monthly")
        XCTAssertEqual(products[1].id, "com.test.yearly")
    }
    
    func testFetchProductsError() async throws {
        subscriptionService.shouldThrowError = true
        
        do {
            _ = try await subscriptionService.fetchProducts(productIds: ["test"])
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is SubscriptionError)
        }
    }
    
    func testPurchaseProduct() async throws {
        let product = SubscriptionProduct(
            id: "com.test.monthly",
            displayName: "Monthly",
            description: "Monthly subscription",
            price: 9.99,
            displayPrice: "$9.99"
        )
        
        let success = try await subscriptionService.purchase(product)
        XCTAssertTrue(success)
        
        let hasSubscription = await subscriptionService.hasActiveSubscription
        XCTAssertTrue(hasSubscription)
    }
    
    func testPurchaseProductError() async throws {
        subscriptionService.shouldThrowError = true
        
        let product = SubscriptionProduct(
            id: "com.test.monthly",
            displayName: "Monthly",
            description: "Monthly subscription",
            price: 9.99,
            displayPrice: "$9.99"
        )
        
        do {
            _ = try await subscriptionService.purchase(product)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is SubscriptionError)
        }
    }
    
    func testRestorePurchases() async throws {
        subscriptionService.mockHasActiveSubscription = true
        let hasActivePurchase = try await subscriptionService.restorePurchases()
        
        XCTAssertTrue(hasActivePurchase)
    }
    
    func testRestorePurchasesNoActivePurchase() async throws {
        subscriptionService.mockHasActiveSubscription = false
        let hasActivePurchase = try await subscriptionService.restorePurchases()
        
        XCTAssertFalse(hasActivePurchase)
    }
    
    func testHasActiveSubscription() async throws {
        var hasSubscription = await subscriptionService.hasActiveSubscription
        XCTAssertFalse(hasSubscription)
        
        subscriptionService.mockHasActiveSubscription = true
        hasSubscription = await subscriptionService.hasActiveSubscription
        XCTAssertTrue(hasSubscription)
    }
    
    func testSubscriptionProduct() throws {
        let product = SubscriptionProduct(
            id: "com.test.monthly",
            displayName: "Monthly Plan",
            description: "Monthly subscription plan",
            price: 9.99,
            displayPrice: "$9.99"
        )
        
        XCTAssertEqual(product.id, "com.test.monthly")
        XCTAssertEqual(product.displayName, "Monthly Plan")
        XCTAssertEqual(product.description, "Monthly subscription plan")
        XCTAssertEqual(product.price, 9.99)
        XCTAssertEqual(product.displayPrice, "$9.99")
    }
}
