//
//  FlexibleWorkzone.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 20.05.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation

public final class FlexibleReadingWorkzone: FlexibleWorkzone {
    public let raw: String
    
    private var readingIndex: Substring.Index
    private var prevReadingIndex: Substring.Index?

    public init(raw: String) {
        self.raw = raw
        
        readingIndex = raw.startIndex
        prevReadingIndex = nil
    }
    
    public final var readingSymbol: Character? {
        guard canRead else { return nil }
        return raw[readingIndex]
    }
    
    public final var rest: Substring {
        guard canRead else { return Substring() }
        return raw[readingIndex...]
    }
    
    public final var canRead: Bool {
        return (readingIndex < raw.endIndex)
    }
    
    public final var isFinished: Bool {
        return (readingIndex == raw.endIndex)
    }
    
    public final func skip(_ number: Int) {
        guard canRead else { return }
        prevReadingIndex = readingIndex
        readingIndex = raw.index(readingIndex, offsetBy: number)
    }
    
    public final func skip(_ number: UInt64) {
        skip(Int(number))
    }
    
    public final func skipIf(pointsTo token: Character) -> Bool {
        guard canRead else { return false }
        
        if token == raw[readingIndex] {
            skip(1)
            return true
        }
        else {
            return false
        }
    }
    
    @discardableResult public final func jumpTo(_ anySymbol: CharacterSet) -> Bool {
        guard canRead else {
            prevReadingIndex = nil
            return false
        }
        
        var index = readingIndex
        while index < raw.endIndex {
            guard let scalar = raw[index].unicodeScalars.first, anySymbol.contains(scalar) else {
                index = raw.index(index, offsetBy: 1)
                continue
            }
            
            prevReadingIndex = readingIndex
            readingIndex = index
            return true
        }
        
        prevReadingIndex = nil
        return false
    }
    
    public final func scanWhile(_ anySymbol: CharacterSet) -> Substring? {
        guard canRead else {
            prevReadingIndex = nil
            return nil
        }
        
        var index = readingIndex
        while index < raw.endIndex {
            guard let scalar = raw[index].unicodeScalars.first, !anySymbol.contains(scalar) else {
                index = raw.index(index, offsetBy: 1)
                continue
            }
            
            guard index > readingIndex else {
                prevReadingIndex = nil
                return nil
            }
            
            let scanned = raw[readingIndex ..< index]
            prevReadingIndex = readingIndex
            readingIndex = index
            return scanned
        }
        
        prevReadingIndex = nil
        return nil
    }
    
    public final func revert() {
        guard let index = prevReadingIndex else { return }
        readingIndex = index
        prevReadingIndex = nil
    }
}
