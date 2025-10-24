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
    var fileStorageService: FileStorageManager!
    var appConfigService: AppConfigManager!

    override func setUpWithError() throws {
        try super.setUpWithError()

        fileStorageService = FileStorageManager(modelContainer: <#T##ModelContainer#>)
        appConfigService = AppConfigManager()
        sfSymbolsProvider = SFSymbolsManager(storageService: fileStorageService,
                                             configProvider: appConfigService)
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
        Task {
            _ = appConfigService.symbols
            promise.fulfill()
        }

        wait(for: [promise], timeout: 1)
    }
    
    func testJsonDataFromFile() throws {
        guard let url = Bundle.main.url(forResource: FileStorageManager.fileName, withExtension: FileStorageManager.fileNameExtension) else { XCTFail("File with such name and extension does not exist"); return }
        let data = try Data(contentsOf: url)
        let _ = try JSONDecoder().decode(SymbolsCategoriesResponse.self, from: data)
    }

    func testFileStorageData() throws {
        let symbols = fileStorageService.sfSymbolsCategories//getSymbols()

        XCTAssertFalse(symbols.isEmpty)
        XCTAssertEqual(symbols.count, 29)
    }
    
    func testLocalSymbolsAvailability() throws {
        var errors: [Error] = []
        let symbolCategories = fileStorageService.sfSymbolsCategories//getSymbols()

        symbolCategories.forEach { category in
            category.sfSymbols.forEach { symbol in
                guard let _ = UIImage(systemName: symbol.id) else {
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

    func testLocalDataSourcePerformance() throws {
        measure {
            _ = fileStorageService.sfSymbolsCategories//getSymbols()
        }
    }

    func testRemoteConfigPerformance() throws {

        measure {
            _ = appConfigService.symbols
        }
    }
}
