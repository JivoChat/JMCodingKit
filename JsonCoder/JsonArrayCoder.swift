//
//  JsonArrayCoder.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 19.05.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation

fileprivate let openerToken = Character("[")
fileprivate let closerToken = Character("]")
fileprivate let separatorToken = Character(",")
fileprivate let gapSymbols = CharacterSet.whitespacesAndNewlines

final class JsonArrayCoder: FlexibleElementCoder {
    final func decode(context: FlexibleContext<FlexibleReadingWorkzone>, extra: Any?) throws -> FlexibleAnyElement? {
        let options = context.anyOptions[JsonCodingOptions.self]
        
        guard
            context.workzone.skipIf(pointsTo: openerToken)
            else { return nil }
        
        var array = [JsonElement]()

        while true {
            context.workzone.jumpTo(gapSymbols.inverted)
            
            if context.workzone.skipIf(pointsTo: closerToken) {
                return FlexibleAnyElement(JsonElement.array(array))
            }
            
            guard
                let anyElement = context.decodeToElement(extra: nil),
                let element = anyElement[JsonElement.self]
                else { return FlexibleAnyElement(JsonElement.failure()) }

            array.append(element)

            context.workzone.jumpTo(gapSymbols.inverted)

            if context.workzone.skipIf(pointsTo: separatorToken) {
                continue
            }
            else if context.workzone.skipIf(pointsTo: closerToken) {
                return FlexibleAnyElement(JsonElement.array(array))
            }
            else {
                return FlexibleAnyElement(JsonElement.failure())
            }
        }
    }
    
    final func encode(context: FlexibleContext<FlexibleWritingWorkzone>, anyElement: FlexibleAnyElement, depth: Int) -> Bool {
        guard case .array(let array) = anyElement[JsonElement.self] else { return false }
        let options = context.anyOptions[JsonCodingOptions.self]
        
        let isPretty = options.contains(.pretty)
        
        context.workzone.append(openerToken)
        if isPretty {
            context.workzone.appendNewline()
            context.workzone.appendTabs(number: depth + 1)
        }
        
        for child in array {
            context.encodeToRaw(
                anyElement: FlexibleAnyElement(child),
                depth: depth + 1)
            
            context.workzone.append(separatorToken)
            if isPretty {
                context.workzone.appendNewline()
                context.workzone.appendTabs(number: depth + 1)
            }
        }
        
        switch (array.isEmpty, isPretty) {
        case (false, false):
            context.workzone.cut(trailing: 1)
        case (false, true):
            context.workzone.cut(downTo: separatorToken, including: true)
            context.workzone.appendNewline()
            context.workzone.appendTabs(number: depth)
        case (true, false):
            break
        case (true, true):
            context.workzone.appendNewline()
            context.workzone.appendTabs(number: depth)
        }

        context.workzone.append(closerToken)
        
        return true
    }
}
