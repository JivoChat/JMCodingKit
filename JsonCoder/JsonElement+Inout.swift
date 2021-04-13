//
//  JsonParserAccessors.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 20.05.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation

extension JsonElement: Codable {
    public init() {
        self = .ordict([:])
    }
    
    public init(_ object: Any) {
        switch object {
        case let dict as [String: Any]: self = .ordict(OrderedMap(dict.mapValues(JsonElement.init)))
        case let array as [Any]: self = .array(array.map(JsonElement.init))
        case let string as String: self = .string(string)
        case let number as NSNumber where CFGetTypeID(number) == CFBooleanGetTypeID(): self = .boolean(number.boolValue)
        case let number as NSNumber: self = .number(number)
        case let boolean as Bool: self = .boolean(boolean)
        case let number as Int: self = .number(NSNumber(value: number))
        case let number as UInt: self = .number(NSNumber(value: number))
        case let number as Int8: self = .number(NSNumber(value: number))
        case let number as UInt8: self = .number(NSNumber(value: number))
        case let number as Int16: self = .number(NSNumber(value: number))
        case let number as UInt16: self = .number(NSNumber(value: number))
        case let number as Int32: self = .number(NSNumber(value: number))
        case let number as UInt32: self = .number(NSNumber(value: number))
        case let number as Int64: self = .number(NSNumber(value: number))
        case let number as UInt64: self = .number(NSNumber(value: number))
        case let number as Double: self = .number(NSNumber(value: number))
        case let number as Float: self = .number(NSNumber(value: number))
        case let null as NSNull: self = .null
        case let string as NSString: self = .string(string as String)
        case let value as JsonElement: self = value
        case let value as OrderedMap<String, JsonElement>: self = .ordict(value)
        case let value as [JsonElement]: self = .array(value)
        default: self = .unknown
        }
    }
    
    public var object: Any {
        switch self {
        case .ordict(let dict): return dict.mapValues({ $0.object }).unOrderedMap
        case .array(let array): return array.map({ $0.object })
        case .number(let number): return number
        case .boolean(let boolean): return boolean
        case .null: return NSNull()
        case .string(let string): return string
        case .unknown: return NSNull()
        }
    }
    
    public init(from decoder: Decoder) throws {
        var container = try decoder.singleValueContainer()
        self = JsonCoder().decode(raw: try container.decode(String.self)) ?? .ordict([:])
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(JsonCoder().encodeToRaw(self))
    }
}

extension JsonElement: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, Any)...) {
        let norm = elements.map { ($0, JsonElement($1)) }
        self = .ordict(OrderedMap(norm))
    }
}

extension JsonElement: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Any...) {
        let norm = elements.map { JsonElement($0) }
        self = .array(norm)
    }
}

extension JsonElement: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self = .string(value)
    }
    
    public init(extendedGraphemeClusterLiteral value: StringLiteralType) {
        self = .string(value)
    }
    
    public init(unicodeScalarLiteral value: StringLiteralType) {
        self = .string(value)
    }
}

extension JsonElement: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: IntegerLiteralType) {
        self = .number(NSNumber(integerLiteral: value))
    }
}

extension JsonElement: ExpressibleByFloatLiteral {
    public init(floatLiteral value: FloatLiteralType) {
        self = .number(NSNumber(floatLiteral: value))
    }
}

extension JsonElement: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: BooleanLiteralType) {
        self = .boolean(value)
    }
}

extension JsonElement: CustomDebugStringConvertible {
    public var debugDescription: String {
        if let raw = JsonCoder().encodeToRaw(self, options: .pretty, depthLimit: 8) {
            return raw + "\n"
        }
        else {
            return "(null)"
        }
    }
}
