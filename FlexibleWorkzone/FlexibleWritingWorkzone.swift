//
//  FlexibleWorkzone.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 20.05.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation

fileprivate let spaceToken = " "
fileprivate let newlineToken = "\n"
fileprivate let tabulateToken = "\t"

public protocol FlexibleWritingWorkzoneBase: class {
    var raw: String { get }
    func append(_ string: String)
    func append(_ string: Substring)
    func append(_ symbol: Character)
    func appendSpace()
    func appendNewline()
    func appendTabs(number: Int)
    func cut(trailing number: Int)
    func cut(downTo token: Character, including: Bool)
}

public final class FlexibleWritingWorkzone: FlexibleWorkzone, FlexibleWritingWorkzoneBase {
    private let impl: FlexibleWritingWorkzoneBase
    
    public init() {
        if #available(iOS 11.0, *) {
            impl = FlexibleWritingWorkzoneSubstringImpl()
        }
        else {
            impl = FlexibleWritingWorkzoneCharacterImpl()
        }
    }
    
    public var raw: String {
        return impl.raw
    }
    
    final public func append(_ string: String) {
        impl.append(string)
    }
    
    final public func append(_ string: Substring) {
        impl.append(string)
    }
    
    final public func append(_ symbol: Character) {
        impl.append(symbol)
    }
    
    final public func appendSpace() {
        impl.appendSpace()
    }
    
    final public func appendNewline() {
        impl.appendNewline()
    }
    
    final public func appendTabs(number: Int) {
        impl.appendTabs(number: number)
    }
    
    final public func cut(trailing number: Int) {
        impl.cut(trailing: number)
    }
    
    final public func cut(downTo token: Character, including: Bool) {
        impl.cut(downTo: token, including: including)
    }
}

public final class FlexibleWritingWorkzoneSubstringImpl: FlexibleWorkzone, FlexibleWritingWorkzoneBase {
    public var substring = Substring()
    
    public init() {
    }
    
    public var raw: String {
        return String(substring)
    }
    
    final public func append(_ string: String) {
        substring.append(contentsOf: string)
    }
    
    final public func append(_ string: Substring) {
        substring.append(contentsOf: string)
    }
    
    final public func append(_ symbol: Character) {
        substring.append(symbol)
    }
    
    final public func appendSpace() {
        append(spaceToken)
    }
    
    final public func appendNewline() {
        append(newlineToken)
    }
    
    final public func appendTabs(number: Int) {
        append(String(repeating: tabulateToken, count: number))
    }
    
    final public func cut(trailing number: Int) {
        substring = substring.dropLast(number)
    }
    
    final public func cut(downTo token: Character, including: Bool) {
        guard let index = substring.lastIndex(of: token), index < substring.endIndex else { return }
        let numToCut = substring.distance(from: index, to: substring.endIndex)
        cut(trailing: including ? numToCut : numToCut - 1)
    }
}

public final class FlexibleWritingWorkzoneCharacterImpl: FlexibleWorkzone, FlexibleWritingWorkzoneBase {
    public var characters = [Character]()
    
    public init() {
    }
    
    public var raw: String {
        return String(characters)
    }
    
    final public func append(_ string: String) {
        characters.append(contentsOf: string)
    }
    
    final public func append(_ string: Substring) {
        characters.append(contentsOf: string)
    }
    
    final public func append(_ symbol: Character) {
        characters.append(symbol)
    }
    
    final public func appendSpace() {
        append(spaceToken)
    }
    
    final public func appendNewline() {
        append(newlineToken)
    }
    
    final public func appendTabs(number: Int) {
        append(String(repeating: tabulateToken, count: number))
    }
    
    final public func cut(trailing number: Int) {
        characters.removeLast(number)
    }
    
    final public func cut(downTo token: Character, including: Bool) {
        guard let index = characters.lastIndex(of: token), index < characters.endIndex else { return }
        let numToCut = characters.distance(from: index, to: characters.endIndex)
        cut(trailing: including ? numToCut : numToCut - 1)
    }
}
