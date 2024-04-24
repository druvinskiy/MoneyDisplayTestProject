//
//  ViewController.swift
//  MoneyDisplayTestProject
//
//  Created by David Ruvinskiy on 4/17/24.
//

import UIKit

class ViewController: UIViewController {
    
    let currencyTextView = CurrencyTextView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        currencyTextView.backgroundColor = .systemBackground
        currencyTextView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(currencyTextView)
        
        NSLayoutConstraint.activate([
            currencyTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            currencyTextView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            currencyTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            currencyTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        currencyTextView.becomeFirstResponder()
    }

}

class CurrencyTextView: UIView, UIKeyInput {
    enum Mode: Equatable {
        case whole
        case fractional(numValues: Int)
        case fractionNoDigits
        case fractionalWithValueInHundredthsPlace
    }
    
    var mode = Mode.whole
    
    var wholeValues = 0
    var fractionalValues = 0
    
    let numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.currencyCode = "USD"
        
        return numberFormatter
    }()
    
    var formattedAmount: String {
        switch mode {
        case .whole:
            numberFormatter.minimumFractionDigits = 0
            return numberFormatter.string(for: wholeValues)!
            
        case .fractionNoDigits:
            numberFormatter.minimumFractionDigits = 2
            return numberFormatter.string(for: wholeValues)!
            
        case .fractional(let numValues):
            let combined = wholeValues.combine(with: fractionalValues)
            let decimal = combined.convertToDecimal(numFractionalValues: numValues)
            
            numberFormatter.minimumFractionDigits = 2
            return numberFormatter.string(from: NSDecimalNumber(decimal: decimal))!
        case .fractionalWithValueInHundredthsPlace:
            let decimal = fractionalValues.convertToDecimal(numFractionalValues: 2)
            let combined = Decimal(wholeValues) + decimal
            
            numberFormatter.minimumFractionDigits = 2
            return numberFormatter.string(from: NSDecimalNumber(decimal: combined))!
        }
    }
    
    override var canBecomeFirstResponder: Bool { true }
    
    var keyboardType: UIKeyboardType = .decimalPad
    
    var hasText: Bool {
        return true
    }
    
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        updateLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func insertText(_ text: String) {
        if text == "." && mode == .whole {
            mode = .fractionNoDigits
            updateLabel()
            
            return
        }
        
        guard let int = Int(text) else {
            return
        }
        
        switch mode {
        case .whole:
            wholeValues = wholeValues * 10 + int
        case .fractional(let numValues):
            if numValues == 2 {
                break
            }
            
            if numValues == 1 && fractionalValues == 0 {
                fractionalValues = int
                mode = .fractionalWithValueInHundredthsPlace
                
                break
            }
            
            mode = .fractional(numValues: 2)
            
            fractionalValues = fractionalValues * 10 + int
        case .fractionNoDigits:
            mode = .fractional(numValues: 1)
            
            fractionalValues = fractionalValues * 10 + int
        case .fractionalWithValueInHundredthsPlace:
            break
        }
        
        updateLabel()
    }
    
    func deleteBackward() {
        switch mode {
        case .whole:
            wholeValues = wholeValues / 10
        case .fractional(var numValues):
            numValues -= 1
            
            if numValues == 0 {
                mode = .fractionNoDigits
            } else {
                mode = .fractional(numValues: numValues)
            }
            
            fractionalValues = fractionalValues / 10
        case .fractionNoDigits:
            mode = .whole
        case .fractionalWithValueInHundredthsPlace:
            mode = .fractional(numValues: 1)
            fractionalValues = fractionalValues / 10
        }
        
        updateLabel()
    }
    
    func updateLabel() {
        var attributedString = AttributedString(formattedAmount)
        
        let range = rangeToColor(for: attributedString)
        attributedString[range].foregroundColor = .red
        
        label.attributedText = NSAttributedString(attributedString)
    }
    
    func rangeToColor(for attributedString: AttributedString) -> Range<AttributedString.Index> {
        var start = attributedString.characters.startIndex
        var end = attributedString.characters.startIndex
        
        switch mode {
        case .whole:
            if wholeValues == 0 {
                start = attributedString.characters.index(attributedString.startIndex, offsetBy: 1)
                end = attributedString.characters.index(start, offsetBy: 1)
            }
        case .fractional(let numFractionalValues):
            let numCommas = formattedAmount.components(separatedBy: ",").count - 1
            let numWholeValues = wholeValues.numberOfDigits()
            let offset = numCommas + numWholeValues + numFractionalValues + 2
            
            start = attributedString.characters.index(attributedString.startIndex, offsetBy: offset)
            end = attributedString.characters.endIndex
        case .fractionNoDigits:
            let numberCommas = formattedAmount.components(separatedBy: ",").count - 1
            let numWholeValues = wholeValues.numberOfDigits()
            let offset = numberCommas + numWholeValues + 2
            
            start = attributedString.characters.index(attributedString.startIndex, offsetBy: offset)
            end = attributedString.characters.endIndex
        case .fractionalWithValueInHundredthsPlace:
            break
        }
        
        return start..<end
    }
}

extension Int {
    func convertToDecimal(numFractionalValues: Int) -> Decimal {
        return Decimal(self) / pow(10, numFractionalValues)
    }
    
    func combine(with value: Int) -> Int {
        let numberOfSecondDigits = value.numberOfDigits()
        let multiplier = pow(Double(10), Double(numberOfSecondDigits))
        
        return self * Int(multiplier) + value
    }
    
    func numberOfDigits() -> Int {
        guard self > 0 else { return 1 }
        
        var count = 0
        var number = self
        while number > 0 {
            number = number / 10
            count += 1
        }
        return count
    }
}
