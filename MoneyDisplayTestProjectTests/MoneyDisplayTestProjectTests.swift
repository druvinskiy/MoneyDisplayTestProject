//
//  MoneyDisplayTestProjectTests.swift
//  MoneyDisplayTestProjectTests
//
//  Created by David Ruvinskiy on 4/21/24.
//

import XCTest
@testable import MoneyDisplayTestProject

//final class MoneyDisplayTestProjectTests: XCTestCase {
//    func test() {
//        let currencyTextView = CurrencyTextView()
//
//        XCTAssertEqual(currencyTextView.formattedAmount, "$0")
//
//        currencyTextView.insertText("1")
//        XCTAssertEqual(currencyTextView.formattedAmount, "$1")
//
//        currencyTextView.insertText(".")
//        XCTAssertEqual(currencyTextView.formattedAmount, "$1.00")
//
//        currencyTextView.insertText("0")
//        XCTAssertEqual(currencyTextView.formattedAmount, "$1.00")
//
//        currencyTextView.insertText("0")
//        XCTAssertEqual(currencyTextView.formattedAmount, "$1.00")
//
//        currencyTextView.deleteBackward()
//        currencyTextView.insertText("1")
//
//        XCTAssertEqual(currencyTextView.formattedAmount, "$1.01")
//    }
//}

final class MoneyDisplayTestProjectTests: XCTestCase {
    private var currencyView: CurrencyTextView!
    
    override func setUpWithError() throws {
        currencyView = CurrencyTextView()
    }
    
    override func tearDownWithError() throws {
        currencyView = nil
    }
    
    func testInitialCondition() {
        XCTAssertEqual(currencyView.formattedAmount, "$0")
    }
    
    func testDecimalModeEntryAndExit() {
        currencyView.insertText("1")
        XCTAssertEqual(currencyView.mode, .whole)
        XCTAssertEqual(currencyView.formattedAmount, "$1")
        
        currencyView.insertText("2")
        XCTAssertEqual(currencyView.mode, .whole)
        XCTAssertEqual(currencyView.formattedAmount, "$12")
        
        currencyView.insertText("3")
        XCTAssertEqual(currencyView.mode, .whole)
        XCTAssertEqual(currencyView.formattedAmount, "$123")
        
        currencyView.insertText(".")
        XCTAssertEqual(currencyView.mode, .fractional)
        XCTAssertEqual(currencyView.formattedAmount, "$123.00")
        
        currencyView.deleteBackward()
        XCTAssertEqual(currencyView.mode, .whole)
        XCTAssertEqual(currencyView.formattedAmount, "$123")
        
    }
}
