//
//  SanFranSymsUITests.swift
//  SanFranSymsUITests
//
//  Created by Vadim Zhuk on 18/07/2022.
//

import XCTest

class SanFranSymsUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // UI tests must launch the application that they test.
//        let app = XCUIApplication()
//        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
//        XCUIApplication().scrollViews.children(matching: .other).element(boundBy: 0).children(matching: .other).element.children(matching: .button).matching(identifier: "Share").element(boundBy: 0).tap()
                
        
//        let app = XCUIApplication()
//        let tablesQuery = app.tables
//        tablesQuery/*@START_MENU_TOKEN@*/.buttons["Fitness (10)"]/*[[".cells[\"Fitness (10)\"].buttons[\"Fitness (10)\"]",".buttons[\"Fitness (10)\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.swipeUp()
//        tablesQuery/*@START_MENU_TOKEN@*/.buttons["Media (79)"]/*[[".cells[\"Media (79)\"].buttons[\"Media (79)\"]",".buttons[\"Media (79)\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.swipeDown()
//        tablesQuery/*@START_MENU_TOKEN@*/.buttons["All (3292)"]/*[[".cells[\"All (3292)\"].buttons[\"All (3292)\"]",".buttons[\"All (3292)\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
//
//        let scrollViewsQuery = app.scrollViews
//        let element = scrollViewsQuery.children(matching: .other).element(boundBy: 0).children(matching: .other).element
//        element.swipeUp()
//        element.swipeDown()
//
//        let elementsQuery = scrollViewsQuery.otherElements
//        elementsQuery.buttons["square.and.arrow.up.trianglebadge.exclamationmark"].tap()
//        app.otherElements["Primary Color"].children(matching: .other).element.children(matching: .button).element.tap()
//        elementsQuery.otherElements["purpurowy 38"].tap()
//        elementsQuery.buttons["zamknij"].tap()
        let tablesQuery = app.tables
//        tablesQuery.buttons["Arrows (326)"].swipeUp()
//        tablesQuery/*@START_MENU_TOKEN@*/.buttons["Media (79)"]/*[[".cells[\"Media (79)\"].buttons[\"Media (79)\"]",".buttons[\"Media (79)\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.swipeDown()
//        tablesQuery/*@START_MENU_TOKEN@*/.buttons["All (3292)"]/*[[".cells[\"All (3292)\"].buttons[\"All (3292)\"]",".buttons[\"All (3292)\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
//        XCUIApplication().scrollViews.children(matching: .other).element(boundBy: 0).children(matching: .other).element.children(matching: .button).matching(identifier: "Share").element(boundBy: 0).tap()
                
    }
    
    func testAppScreens() throws {
        // open category
        
//        let tablesQuery = app.tables
////        tablesQuery.buttons["Arrows (326)"].swipeUp()
////        tablesQuery/*@START_MENU_TOKEN@*/.buttons["Media (79)"]/*[[".cells[\"Media (79)\"].buttons[\"Media (79)\"]",".buttons[\"Media (79)\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.swipeDown()
//        tablesQuery/*@START_MENU_TOKEN@*/.buttons["All (3292)"]/*[[".cells[\"All (3292)\"].buttons[\"All (3292)\"]",".buttons[\"All (3292)\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
//
//        // open symbol
//        let collectionQuery = app.scrollViews.otherElements
//        collectionQuery.element(boundBy: 0).children(matching: .other).element.children(matching: .button).matching(identifier: "Share").element(boundBy: 0).tap()
//        collectionQuery.buttons["square.and.arrow.up.trianglebadge.exclamationmark"].tap()
//        
//        // set rendering mode
//        let elementsQuery = app.otherElements
//        
//        app.buttons["Rendering mode"].tap()
//        app.collectionViews/*@START_MENU_TOKEN@*/.buttons["Palette"]/*[[".cells.buttons[\"Palette\"]",".buttons[\"Palette\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
//        
//        // set primary color
//        elementsQuery["Primary Color"].children(matching: .other).element.children(matching: .button).element.tap()
//        elementsQuery.otherElements["różowy 39"].tap()
//        elementsQuery.buttons["zamknij"].tap()
//        // set secondary color
//        elementsQuery["Secondary Color"].children(matching: .other).element.children(matching: .button).element.tap()
//        elementsQuery.otherElements["cyjan 63"].tap()
//        elementsQuery.buttons["zamknij"].tap()
//        
//        makeScreenShot()
//        sleep(1)
        
    }
    
    private func makeScreenShot() {
        let screenshot = XCUIScreen.main.screenshot()
        let fullScreenshotAttachment = XCTAttachment(screenshot: screenshot)
        fullScreenshotAttachment.lifetime = .keepAlways

        add(fullScreenshotAttachment)
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
