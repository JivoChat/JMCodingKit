//
//  JsonNumberCoder.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 19.05.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation

fileprivate let signToken = "-"
fileprivate let dotToken = "."
fileprivate let allowedSymbols = CharacterSet.decimalDigits.union(CharacterSet(charactersIn: signToken + dotToken))

final class JsonNumberCoder: FlexibleElementCoder {
    private let formatter = NumberFormatter()
    
    public init() {
        formatter.decimalSeparator = dotToken
        formatter.groupingSeparator = String()
    }
    
    final func decode(context: FlexibleContext<FlexibleReadingWorkzone>, extra: Any?) throws -> FlexibleAnyElement? {
        guard let source = context.workzone.scanWhile(allowedSymbols) else {
            return nil
        }
        
        if let number = formatter.number(from: String(source)) {
            return FlexibleAnyElement(JsonElement.number(number))
        }
        else {
            return FlexibleAnyElement(JsonElement.failure())
        }
    }
    
    final func encode(context: FlexibleContext<FlexibleWritingWorkzone>, anyElement: FlexibleAnyElement, depth: Int) -> Bool {
        guard case .number(let number) = anyElement[JsonElement.self] else { return false }
        let options = context.anyOptions[JsonCodingOptions.self]
        
        context.workzone.append(number.stringValue)
        return true
    }
}
