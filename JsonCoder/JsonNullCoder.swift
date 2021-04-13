//
//  JsonNullCoder.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 19.05.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation

fileprivate let nullToken = Substring("null")

final class JsonNullCoder: FlexibleElementCoder {
    final func decode(context: FlexibleContext<FlexibleReadingWorkzone>, extra: Any?) throws -> FlexibleAnyElement? {
        switch context.workzone.scanWhile(CharacterSet.letters) {
        case nullToken:
            return FlexibleAnyElement(JsonElement.null)
        case nil:
            return nil
        default:
            context.workzone.revert()
            return nil
        }
    }
    
    final func encode(context: FlexibleContext<FlexibleWritingWorkzone>, anyElement: FlexibleAnyElement, depth: Int) -> Bool {
        guard case .null = anyElement[JsonElement.self] else { return false }
        let options = context.anyOptions[JsonCodingOptions.self]
        
        context.workzone.append(nullToken)
        return true
    }
}
