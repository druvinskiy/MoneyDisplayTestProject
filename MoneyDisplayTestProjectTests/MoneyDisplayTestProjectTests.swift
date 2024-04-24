//
//  MoneyDisplayTestProjectTests.swift
//  MoneyDisplayTestProjectTests
//
//  Created by David Ruvinskiy on 4/21/24.
//

import XCTest
@testable import MoneyDisplayTestProject

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
        insertText("1")
        XCTAssertEqual(currencyView.formattedAmount, "$1")
        
        insertText("2")
        XCTAssertEqual(currencyView.formattedAmount, "$12")
        
        insertText("3")
        XCTAssertEqual(currencyView.formattedAmount, "$123")
        
        insertText(".")
        XCTAssertEqual(currencyView.formattedAmount, "$123.00")
        
        deleteBackward()
        XCTAssertEqual(currencyView.formattedAmount, "$123")
    }
    
    func testFractionWithValueInHundredthsPlace() {
        insertText(".")
        XCTAssertEqual(currencyView.formattedAmount, "$0.00")
        
        insertText("0")
        XCTAssertEqual(currencyView.formattedAmount, "$0.00")
        
        insertText("1")
        XCTAssertEqual(currencyView.formattedAmount, "$0.01")
        
        deleteBackward()
        XCTAssertEqual(currencyView.formattedAmount, "$0.00")
        
        deleteBackward()
        XCTAssertEqual(currencyView.formattedAmount, "$0.00")
        
        insertText("1")
        XCTAssertEqual(currencyView.formattedAmount, "$0.10")
        
        deleteBackward()
        XCTAssertEqual(currencyView.formattedAmount, "$0.00")
        
        deleteBackward()
        XCTAssertEqual(currencyView.formattedAmount, "$0")
    }
    
    func testBigWholeValueWithFraction() {
        insertText("123456789")
        XCTAssertEqual(currencyView.formattedAmount, "$123,456,789")
        
        insertText(".12")
        XCTAssertEqual(currencyView.formattedAmount, "$123,456,789.12")
        
        deleteBackward(num: 2)
        XCTAssertEqual(currencyView.formattedAmount, "$123,456,789.00")
        
        deleteBackward()
        XCTAssertEqual(currencyView.formattedAmount, "$123,456,789")
    }
    
    func testResetToInitialCondition() {
        let toInsert = "123456789"
        
        insertText(toInsert)
        deleteBackward(num: toInsert.count)
        
        XCTAssertEqual(currencyView.formattedAmount, "$0")
    }
    
    func testDeleteInitialCondition() {
        deleteBackward(num: 2)
        XCTAssertEqual(currencyView.formattedAmount, "$0")
    }
    
    func testNoWholeValues() {
        insertText(".02")
        XCTAssertEqual(currencyView.formattedAmount, "$0.02")
    }
    
    func testMultipleDecimalPoints() {
        var toInsert = "1..23"
        
        insertText(toInsert)
        
        XCTAssertEqual(currencyView.formattedAmount, "$1.23")
        
        deleteBackward(num: toInsert.count)
        
        XCTAssertEqual(currencyView.formattedAmount, "$0")
        
        toInsert = "1234..56"
        insertText(toInsert)
        
        XCTAssertEqual(currencyView.formattedAmount, "$1,234.56")
    }
    
    func testMoreThanTwoFractionalValues() {
        insertText("123.456")
        XCTAssertEqual(currencyView.formattedAmount, "$123.45")
        
        deleteBackward()
        insertText("6")
        
        XCTAssertEqual(currencyView.formattedAmount, "$123.46")
    }
    
    func testModeSwitching() {
        insertText("123456")
        XCTAssertEqual(currencyView.formattedAmount, "$123,456")
        
        insertText(".")
        XCTAssertEqual(currencyView.formattedAmount, "$123,456.00")
        
        deleteBackward()
        XCTAssertEqual(currencyView.formattedAmount, "$123,456")
        
        insertText("789")
        XCTAssertEqual(currencyView.formattedAmount, "$123,456,789")
        
        insertText(".12")
        XCTAssertEqual(currencyView.formattedAmount, "$123,456,789.12")
    }
    
    private func insertText(_ text: String) {
        for index in text.indices {
            currencyView.insertText(String(text[index]))
        }
    }
    
    private func deleteBackward(num: Int = 1) {
        for _ in 1...num {
            currencyView.deleteBackward()
        }
    }
}
