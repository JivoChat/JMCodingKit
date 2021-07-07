//
//  JsonOrdictCoder.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 19.05.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation

fileprivate let openerToken = Character("{")
fileprivate let closerToken = Character("}")
fileprivate let assignerToken = Character(":")
fileprivate let separatorToken = Character(",")
fileprivate let assignerSymbols = CharacterSet(charactersIn: String(assignerToken))
fileprivate let separatorSymbols = CharacterSet(charactersIn: String(separatorToken))
fileprivate let gapSymbols = CharacterSet.whitespacesAndNewlines

final class JsonOrdictCoder: FlexibleElementCoder {
    final func decode(context: FlexibleContext<FlexibleReadingWorkzone>, extra: Any?) throws -> FlexibleAnyElement? {
        let options = context.anyOptions[JsonCodingOptions.self]
        
        guard
            context.workzone.skipIf(pointsTo: openerToken)
            else { return nil }
        
        var ordict = OrderedMap<String, JsonElement>()
        
        while true {
            context.workzone.jumpTo(gapSymbols.inverted)
            
            if context.workzone.skipIf(pointsTo: closerToken) {
                return FlexibleAnyElement(JsonElement.ordict(ordict))
            }
            
            guard
                let keyAnyElement = context.decodeToElement(extra: JsonCodingOptions.unquotedKey),
                let keyElement = keyAnyElement[JsonElement.self],
                case .string(let key) = keyElement
                else { return FlexibleAnyElement(JsonElement.failure()) }
        
            if context.workzone.jumpTo(assignerSymbols) {
                context.workzone.skip(1)
            }
            else {
                return FlexibleAnyElement(JsonElement.failure())
            }
            
            context.workzone.jumpTo(gapSymbols.inverted)
            
            guard
                let objectKeyElement = context.decodeToElement(extra: nil),
                let objectElement = objectKeyElement[JsonElement.self]
                else { return FlexibleAnyElement(JsonElement.failure()) }
            
            ordict[key] = objectElement
            
            context.workzone.jumpTo(gapSymbols.inverted)
            
            if context.workzone.skipIf(pointsTo: separatorToken) {
                continue
            }
            else if context.workzone.skipIf(pointsTo: closerToken) {
                return FlexibleAnyElement(JsonElement.ordict(ordict))
            }
            else {
                return FlexibleAnyElement(JsonElement.failure())
            }
        }
    }
    
    final func encode(context: FlexibleContext<FlexibleWritingWorkzone>, anyElement: FlexibleAnyElement, depth: Int) -> Bool {
        guard case .ordict(let ordict) = anyElement[JsonElement.self] else { return false }
        let options = context.anyOptions[JsonCodingOptions.self]
        
        let isPretty = options.contains(.pretty)
        
        context.workzone.append(openerToken)
        if isPretty {
            context.workzone.appendNewline()
            context.workzone.appendTabs(number: depth + 1)
        }
        
        for (key, value) in ordict {
            let keyRaw = context.encodeToRaw(
                anyElement: FlexibleAnyElement(JsonElement.string(key)),
                depth: depth)
            
            if isPretty {
                context.workzone.appendSpace()
            }
            
            context.workzone.append(assignerToken)
            if isPretty {
                context.workzone.appendSpace()
            }
            
            let objectRaw = context.encodeToRaw(
                anyElement: FlexibleAnyElement(value),
                depth: depth + 1)
            
            context.workzone.append(separatorToken)
            if isPretty {
                context.workzone.appendNewline()
                context.workzone.appendTabs(number: depth + 1)
            }
        }
        
        switch (ordict.isEmpty, isPretty) {
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
