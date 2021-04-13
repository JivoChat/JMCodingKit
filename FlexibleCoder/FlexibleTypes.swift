//
//  FlexibleCoderTypes.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 20.05.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation

public protocol FlexibleElement: Codable {
    static func failure() -> Self
}

public struct FlexibleAnyElement {
    public var base: Any
    public init<T>(_ value: T) where T: FlexibleElement { self.base = value }
    subscript<T: FlexibleElement>(_ type: T.Type) -> T! { base as! T }
}

public protocol FlexibleCodingOptions: OptionSet {
    func verboseLogging() -> Bool
}

public struct FlexibleAnyCodingOptions {
    public var base: Any
    public init<T>(_ base: T) where T: FlexibleCodingOptions { self.base = base }
    subscript<T: FlexibleCodingOptions>(_ type: T.Type) -> T { base as! T }
    func contains<T: FlexibleCodingOptions>(_ value: T) -> Bool { self[T].contains(value as! T.Element) }
    func union<T: FlexibleCodingOptions>(_ another: T) -> FlexibleAnyCodingOptions { FlexibleAnyCodingOptions(self[T].union(another)) }
}
