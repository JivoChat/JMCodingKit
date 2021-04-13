//
//  FlexibleContext.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 20.05.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation

public final class FlexibleContext<Workzone: FlexibleWorkzone> {
    public let workzone: Workzone
    public let coders: [FlexibleElementCoder]
    public let anyOptions: FlexibleAnyCodingOptions
    public let depthLimit: Int
    
    public init(workzone: Workzone, coders: [FlexibleElementCoder], anyOptions: FlexibleAnyCodingOptions, depthLimit: Int) {
        self.workzone = workzone
        self.coders = coders
        self.anyOptions = anyOptions
        self.depthLimit = depthLimit
    }
    
    public final func decodeToElement(extra: Any?) -> FlexibleAnyElement? {
        guard let readingContext = self as? FlexibleContext<FlexibleReadingWorkzone> else {
            return nil
        }
        
        for decoder in coders {
            guard let element = try? decoder.decode(context: readingContext, extra: extra) else { continue }
            return element
        }
        
        return nil
    }
    
    public final func encodeToRaw(anyElement: FlexibleAnyElement, depth: Int) {
        guard let writingContext = self as? FlexibleContext<FlexibleWritingWorkzone> else {
            return
        }
        
        for encoder in coders {
            if encoder.encode(context: writingContext, anyElement: anyElement, depth: depth) {
                break
            }
            else {
                continue
            }
        }
    }
}
