//
//  PlaceholderTextInputFormatter.swift
//  AnyFormatKit
//
//  Created by Oleksandr Orlov on 12.11.2020.
//  Copyright © 2020 Oleksandr Orlov. All rights reserved.
//

import UIKit

open class PlaceholderTextInputFormatter: TextInputFormatter, TextUnformatter {
    
    // MARK: - Dependencies
    
    private let caretPositionCorrector: CaretPositionCorrector
    private let textFormatter: PlaceholderTextFormatter
    private let stringCalculator: StringCalculator
    
    // MARK: - Properties
    
    var textPattern: String { textFormatter.textPattern }
    var patternSymbol: Character { textFormatter.patternSymbol }
    
    // MARK: - Life cycle
    
    public init(
        textPattern: String,
        patternSymbol: Character = "#"
    ) {
        self.caretPositionCorrector = CaretPositionCorrector(
            textPattern: textPattern,
            patternSymbol: patternSymbol
        )
        self.textFormatter = PlaceholderTextFormatter(
            textPattern: textPattern,
            patternSymbol: patternSymbol
        )
        self.stringCalculator = StringCalculator()
    }
    
    // MARK: - TextInputFormatter
    
    public func formatInput(currentText: String, range: NSRange, replacementString text: String) -> FormattedTextValue {
        guard let swiftRange = Range(range, in: currentText) else { return .zero }
        let oldUnformattedText = textFormatter.unformat(currentText) ?? ""
        
        let unformattedCurrentTextRange = stringCalculator.unformattedRange(currentText: currentText, textPattern: textPattern, from: swiftRange)
        let unformattedRange = oldUnformattedText.getSameRange(asIn: currentText, sourceRange: unformattedCurrentTextRange)
        
        let newText = oldUnformattedText.replacingCharacters(in: unformattedRange, with: text)
        
        let formattedText = textFormatter.format(newText) ?? ""
        let formattedTextRange = formattedText.getSameRange(asIn: currentText, sourceRange: swiftRange)
        
        let caretOffset = getCorrectedCaretPosition(newText: formattedText, range: formattedTextRange, replacementString: text)
        
        return FormattedTextValue(formattedText: formattedText, caretBeginOffset: caretOffset)
    }
    
    // MARK: - TextUnformatter
    
    open func unformat(_ formattedText: String?) -> String? {
        return textFormatter.unformat(formattedText)
    }
    
    // MARK: - Caret position calculation
    
    private func getCorrectedCaretPosition(newText: String, range: Range<String.Index>, replacementString: String) -> Int {
        return caretPositionCorrector.calculateCaretPositionOffset(
            newText: newText,
            originalRange: range,
            replacementText: replacementString
        )
    }
    
}
