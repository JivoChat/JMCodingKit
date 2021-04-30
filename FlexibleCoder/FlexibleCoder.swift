//
//  FlexibleCoder.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 20.05.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import os

open class FlexibleCoder<Element: FlexibleElement, Options: FlexibleCodingOptions> {
    public init() {
    }
    
    open var coders: [FlexibleElementCoder] {
        preconditionFailure("Please specify decoders in subclass")
    }
    
    public func decode(raw: String, options: Options = []) -> Element? {
        let startedAt = Date()
        defer {
            if options.verboseLogging() {
                let duration = Date().timeIntervalSince(startedAt)
                print("FlexibleCoder: spent \(duration) seconds for decoding '\(raw.prefix(64))' [\(raw.count)]")
            }
        }
        
        let object = decodeToElement(
            context: FlexibleContext(
                workzone: FlexibleReadingWorkzone(raw: raw),
                coders: coders,
                anyOptions: FlexibleAnyCodingOptions(options),
                depthLimit: .max
            )
        )
        
        return object?[Element]
    }
    
    public final func decode(binary: Data, encoding: String.Encoding, options: Options = []) -> Element? {
        if let raw = String(data: binary, encoding: encoding) {
            return decode(raw: raw, options: options)
        }
        else {
            return nil
        }
    }
    
    public final func encodeToRaw(_ element: Element, options: Options = [], depthLimit: Int = .max) -> String? {
        let workzone = FlexibleWritingWorkzone()
        let context = FlexibleContext(workzone: workzone, coders: coders, anyOptions: FlexibleAnyCodingOptions(options), depthLimit: depthLimit)
        encodeToRaw(context: context, anyElement: FlexibleAnyElement(element), depth: 0)
        return String(workzone.raw)
    }
    
    public final func encodeToBinary(_ element: Element, encoding: String.Encoding, options: Options = [], depthLimit: Int = .max) -> Data? {
        let raw = encodeToRaw(element, options: options, depthLimit: depthLimit)
        return raw?.data(using: encoding)
    }
    
    private final func decodeToElement(context: FlexibleContext<FlexibleReadingWorkzone>) -> FlexibleAnyElement? {
        if let element = context.decodeToElement(extra: nil), context.workzone.isFinished {
            return element
        }
        else {
            return nil
        }
    }
    
    internal final func encodeToRaw(context: FlexibleContext<FlexibleWritingWorkzone>, anyElement: FlexibleAnyElement, depth: Int) {
        context.encodeToRaw(anyElement: anyElement, depth: depth)
    }
}
