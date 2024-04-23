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
        // Do any additional setup after loading the view.
        
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
    /*
     
     Dollar sign is always visible (cannot delete it)
     When there's no text entered, we see a greyed out 0.
     Commas are added automatically as the user types
     
     
     
     When the user adds a decimal, the 00s are added automatically in grey
     If there's a single decimal #, the user's number is a regular color and the remaining 0 is grey
     
     If two decimals are entered, backspacing brings back the 0 decimal in grey
     
     If the user backspaces all the way back to the whole number, add commas as they keep typing until they add the decimal back
     
     If the user backspaces all the way back, display the original greyed out 0
     
     The UI prevents the user from entering more than two decimal digits
     
     Test cases:
     $ -> 6 -> $6
     $6 -> 5 -> $65
     $65 -> 7 $657
     $657 -> 8 -> $6,578
     */
    
    enum Mode {
        case whole
        case fractional
    }
    
    var mode = Mode.whole
    
    var wholeValues = 0
    var fractionalValues = 0
    var numFractionalValues = 0
    
    var formattedAmount: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.minimumFractionDigits = mode == .whole ? 0 : 2
        numberFormatter.numberStyle = .currency
        numberFormatter.currencyCode = "USD"
        
        if fractionalValues > 0 {
            if numFractionalValues == fractionalValues.numberOfDigits() {
                let combined = wholeValues.combine(with: fractionalValues)
                let decimalValue = combined.convertToDecimal(numFractionalValues: numFractionalValues)
                
                return numberFormatter.string(from: NSDecimalNumber(decimal: decimalValue))!
            }
            
            let decimalValue = Decimal(fractionalValues) / Decimal(100)
            let combined = Decimal(wholeValues) + decimalValue
            
            return numberFormatter.string(from: NSDecimalNumber(decimal: combined))!
        }
        
        return numberFormatter.string(for: wholeValues)!
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
        if text == "." {
            mode = .fractional
            updateLabel()
            
            return
        }
        
        guard let int = Int(text) else { return }
        
        switch mode {
        case .fractional:
            guard numFractionalValues < 2 else { return }
            
            fractionalValues = fractionalValues * 10 + int
            numFractionalValues += 1
        case .whole:
            wholeValues = wholeValues * 10 + int
        }
        
        updateLabel()
    }
    
    func deleteBackward() {
        switch mode {
        case .whole:
            wholeValues = wholeValues / 10
        case .fractional:
            fractionalValues = fractionalValues / 10
            
            if numFractionalValues == 0 {
                mode = .whole
            } else {
                numFractionalValues -= 1
            }
        }
        
        updateLabel()
    }
    
    func updateLabel() {
//        var attributedString = AttributedString(formatted)
//        let start = attributedString.characters.index(attributedString.startIndex, offsetBy: 1)
//        let end = attributedString.characters.index(start, offsetBy: 2)
//        attributedString[start..<end].foregroundColor = .red
//
//        label.attributedText = NSAttributedString(attributedString)
        
        label.text = formattedAmount
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
