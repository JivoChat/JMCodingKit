//
//  JsonStringCoder.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 19.05.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation

fileprivate let quoteToken = Character("\"")
fileprivate let specialToken = Character("\\")
fileprivate let unicodeToken = Character("u")
fileprivate let slashToken = Character("/")
fileprivate let newlineToken = Character("n")
fileprivate let tabulateToken = Character("t")
fileprivate let newlineReplacement = Character("\n")
fileprivate let tabulateReplacement = Character("\t")
fileprivate let quoteSymbols = CharacterSet(charactersIn: String(quoteToken))
fileprivate let alphanumSymbols = CharacterSet.alphanumerics
fileprivate let unicodeTransformKey = NSString("Any-Hex/Java")

final class JsonStringCoder: FlexibleElementCoder {
    private var result = String()
    
    private let encodingSpecialFrom = String(specialToken)
    private let encodingSpecialTo = String(specialToken) + String(specialToken)
    private let encodingQuoteFrom = String(quoteToken)
    private let encodingQuoteTo = String(specialToken) + String(quoteToken)
    private let encodingNewlineFrom = String(newlineReplacement)
    private let encodingNewlineTo = String(specialToken) + String(newlineToken)
    private let encodingTabulateFrom = String(tabulateReplacement)
    private let encodingTabulateTo = String(specialToken) + String(tabulateToken)
    
    final func decode(context: FlexibleContext<FlexibleReadingWorkzone>, extra: Any?) throws -> FlexibleAnyElement? {
        let options = context.anyOptions[JsonCodingOptions.self]
        
        guard
            context.workzone.skipIf(pointsTo: quoteToken)
            else { return nil }
        
        result.removeAll(keepingCapacity: true)
        
        if let op = extra as? JsonCodingOptions, op.contains(.unquotedKey) {
            if let scanned = context.workzone.scanWhile(quoteSymbols.inverted) {
                context.workzone.skipIf(pointsTo: quoteToken)
                
                let key = String(scanned)
                return FlexibleAnyElement(JsonElement.string(key))
            }
            else {
                return FlexibleAnyElement(JsonElement.failure())
            }
        }
        else {
            let emptySymbol = Character(" ")
            var rememberSymbol = emptySymbol
            
            for (index, symbol) in context.workzone.rest.enumerated() {
                switch (symbol, rememberSymbol) {
                case (quoteToken, specialToken):
                    result.append(quoteToken)
                    rememberSymbol = emptySymbol
                case (specialToken, specialToken):
                    result.append(specialToken)
                    rememberSymbol = emptySymbol
                case (slashToken, specialToken):
                    result.append(slashToken)
                    rememberSymbol = emptySymbol
                case (unicodeToken, specialToken):
                    result.append(specialToken)
                    result.append(unicodeToken)
                    rememberSymbol = emptySymbol
                case (newlineToken, specialToken):
                    result.append(newlineReplacement)
                    rememberSymbol = emptySymbol
                case (tabulateToken, specialToken):
                    result.append(tabulateReplacement)
                    rememberSymbol = emptySymbol
                case (_, specialToken):
                    rememberSymbol = emptySymbol
                case (specialToken, _):
                    rememberSymbol = symbol
                case (quoteToken, _):
                    let norm: NSMutableString
                    if result.isEmpty {
                        norm = NSMutableString()
                    }
                    else {
                        norm = NSMutableString(string: result)
                        CFStringTransform(norm, nil, unicodeTransformKey, true)
                    }
                    
                    context.workzone.skip(index + 1)
                    return FlexibleAnyElement(JsonElement.string(norm as String))
                default:
                    result.append(symbol)
                }
            }
        }

        return FlexibleAnyElement(JsonElement.failure())
    }
    
    final func encode(context: FlexibleContext<FlexibleWritingWorkzone>, anyElement: FlexibleAnyElement, depth: Int) -> Bool {
        guard case .string(let string) = anyElement[JsonElement.self] else { return false }
        let options = context.anyOptions[JsonCodingOptions.self]
        
        context.workzone.append(quoteToken)
        context.workzone.append(
            (string as NSString)
                .replacingOccurrences(of: encodingSpecialFrom, with: encodingSpecialTo)
                .replacingOccurrences(of: encodingQuoteFrom, with: encodingQuoteTo)
                .replacingOccurrences(of: encodingNewlineFrom, with: encodingNewlineTo)
                .replacingOccurrences(of: encodingTabulateFrom, with: encodingTabulateTo)
        )
        context.workzone.append(quoteToken)
        
        return true
    }
}
