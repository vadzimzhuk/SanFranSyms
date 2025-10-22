# Subscription Service

This document describes how to use the Subscription Service implemented in the SanFranSyms app.

## Overview

The Subscription Service provides a unified interface for managing in-app subscriptions using StoreKit 2 (iOS 15+). It supports:

1. Fetching subscription products from the App Store
2. Purchasing subscriptions
3. Restoring previous purchases
4. Checking active subscription status

## Architecture

### Components

- **SubscriptionProduct**: Entity model representing a subscription product
- **SubscriptionService**: Protocol defining the subscription service interface
- **SubscriptionManager**: Implementation using StoreKit 2 (iOS 15+)

### Dependencies

The service is integrated into the app through:
- `DependencyBuilder.subscriptionService` - Singleton instance
- `EnvironmentValues.subscriptionService` - SwiftUI environment key

## Usage

### 1. Accessing the Service

In SwiftUI views, access the service through the environment:

```swift
@Environment(\.subscriptionService) var subscriptionService
```

### 2. Fetching Products

Fetch subscription products from the App Store:

```swift
let productIds = ["com.yourapp.monthly", "com.yourapp.yearly"]
let products = try await subscriptionService?.fetchProducts(productIds: productIds)
```

### 3. Purchasing a Subscription

Purchase a subscription:

```swift
let success = try await subscriptionService?.purchase(product)
if success {
    // Purchase completed
} else {
    // User cancelled or purchase pending
}
```

### 4. Restoring Purchases

Restore previous purchases:

```swift
let hasActivePurchase = try await subscriptionService?.restorePurchases()
if hasActivePurchase {
    // User has active subscription
}
```

### 5. Checking Subscription Status

Check if user has an active subscription:

```swift
if let hasSubscription = await subscriptionService?.hasActiveSubscription {
    if hasSubscription {
        // User has active subscription
    }
}
```

## Example Implementation

See `SubscriptionExampleView.swift` for a complete example showing:
- Loading products
- Displaying subscription options
- Handling purchases
- Restoring purchases
- Error handling

## Requirements

- iOS 15.0 or later (for StoreKit 2)
- Proper App Store Connect configuration with subscription products

## Testing

The service includes comprehensive unit tests with a mock implementation:
- `SubscriptionServiceTests.swift` - Tests all service methods
- `MockSubscriptionService` - Mock implementation for testing

## Error Handling

The service throws `SubscriptionError` for various failure scenarios:
- `.failedVerification` - Transaction verification failed
- `.productNotFound` - Requested product not found
- `.purchaseFailed` - Purchase failed
- `.unknown` - Unknown error

## Notes

- The service is optional and returns `nil` for iOS versions below 15.0
- Transactions are automatically verified and finished
- The service listens for transaction updates in the background
- All operations are async/await based
