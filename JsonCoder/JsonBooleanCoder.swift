//
//  JsonBooleanCoder.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 19.05.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation

fileprivate let trueToken = Substring("true")
fileprivate let falseToken = Substring("false")

final class JsonBooleanCoder: FlexibleElementCoder {
    final func decode(context: FlexibleContext<FlexibleReadingWorkzone>, extra: Any?) throws -> FlexibleAnyElement? {
        switch context.workzone.scanWhile(CharacterSet.letters) {
        case trueToken:
            return FlexibleAnyElement(JsonElement.boolean(true))
        case falseToken:
            return FlexibleAnyElement(JsonElement.boolean(false))
        case nil:
            return nil
        default:
            context.workzone.revert()
            return nil
        }
    }
    
    final func encode(context: FlexibleContext<FlexibleWritingWorkzone>, anyElement: FlexibleAnyElement, depth: Int) -> Bool {
        guard case .boolean(let boolean) = anyElement[JsonElement.self] else { return false }
        let options = context.anyOptions[JsonCodingOptions.self]
        
        context.workzone.append(boolean ? trueToken : falseToken)
        return true
    }
}
