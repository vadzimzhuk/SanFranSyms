//
//  SanFranSymsTests.swift
//  SanFranSymsTests
//
//  Created by Vadim Zhuk on 18/07/2022.
//

import XCTest

@testable import SanFranSyms

class SanFranSymsTests: XCTestCase {
    
    var sfSymbolsProvider: SanFranSyms.SFSymbolsProvider!
    var sfSymbolCategories: [SanFranSyms.SymbolsCategory]!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        
        sfSymbolsProvider = SanFranSyms.SFSymbolsManager()
        sfSymbolCategories = sfSymbolsProvider.allCategories
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sfSymbolCategories = nil
        sfSymbolsProvider = nil
        
        try super.tearDownWithError()
    }

    func testAsyncExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
        let promise = expectation(description: "ok")
        DispatchQueue.main.async {
            sleep(1)
            promise.fulfill()
        }
        wait(for: [promise], timeout: 1)
    }
    
    func testJsonData() throws {
        guard let url = Bundle.main.url(forResource: FileStorageManager.fileName, withExtension: FileStorageManager.fileNameExtension) else { XCTFail("File with such name and extension does not exist"); return }
        let data = try Data(contentsOf: url)
        let _ = try JSONDecoder().decode(SymbolsCategoriesResponse.self, from: data)
    }
    
    func testSymbolAvailability() throws {
        var errors: [Error] = []
        
        sfSymbolCategories.forEach { category in
            category.symbols.forEach { symbol in
                guard let _ = UIImage(systemName: symbol) else {
                    errors.append(NSError(domain: "Symbol \"\(symbol)\" is not supported", code: 1))
                    return
                }
                
            }
        }
        
        let message: String = errors
            .map{ ($0 as NSError).domain }
            .joined()
        
        XCTAssert(errors.isEmpty, message)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
