//
//  JsonTypes.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 19.05.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation

extension JsonElement {
    public subscript(_ key: String) -> JsonElement {
        get {
            if case .ordict(let ordict) = self {
                return ordict[key] ?? .unknown
            }
            else {
                return .unknown
            }
        }
        set {
            if case .ordict(let ordict) = self {
                self = merged(with: [key: newValue])
            }
            else {
                self = .unknown
            }
        }
    }
    
    public subscript(_ index: Int) -> JsonElement {
        if case .array(let array) = self {
            return array[index]
        }
        else {
            return .unknown
        }
    }
    
    public var dictObject: [String: Any] {
        if let ret = object as? [String: Any] {
            return ret
        }
        else {
            return [:]
        }
    }
    
    public var count: Int {
        return array?.count ?? ordict?.count ?? 0
    }
    
    public var ordict: OrderedMap<String, JsonElement>? {
        if case .ordict(let ordict) = self {
            return ordict
        }
        else {
            return nil
        }
    }

    public var ordictValue: OrderedMap<String, JsonElement> {
        return ordict ?? [:]
    }
    
    public var array: [JsonElement]? {
        if case .array(let array) = self {
            return array
        }
        else {
            return nil
        }
    }

    public var arrayValue: [JsonElement] {
        return array ?? []
    }
    
    public var number: NSNumber? {
        if case .number(let number) = self {
            return number
        }
        else if case .boolean(let boolean) = self {
            return NSNumber(value: boolean ? 1 : 0)
        }
        else {
            return nil
        }
    }

    public var numberValue: NSNumber {
        if case .number(let number) = self {
            return number
        }
        else if case .boolean(let boolean) = self {
            return NSNumber(value: boolean ? 1 : 0)
        }
        else if case .string(let string) = self {
            return NSDecimalNumber(string: string)
        }
        else {
            return NSNumber(value: 0)
        }
    }
    
    public var int: Int? {
        return number?.intValue
    }
    
    public var intValue: Int {
        return numberValue.intValue
    }
    
    public var int8: Int8? {
        return number?.int8Value
    }
    
    public var int8Value: Int8 {
        return numberValue.int8Value
    }
    
    public var int16: Int16? {
        return number?.int16Value
    }
    
    public var int16Value: Int16 {
        return numberValue.int16Value
    }
    
    public var int32: Int32? {
        return number?.int32Value
    }
    
    public var int32Value: Int32 {
        return numberValue.int32Value
    }
    
    public var int64: Int64? {
        return number?.int64Value
    }
    
    public var int64Value: Int64 {
        return numberValue.int64Value
    }
    
    public var uint: UInt? {
        return number?.uintValue
    }
    
    public var uintValue: UInt {
        return numberValue.uintValue
    }
    
    public var uint8: UInt8? {
        return number?.uint8Value
    }
    
    public var uint8Value: UInt8 {
        return numberValue.uint8Value
    }
    
    public var uint16: UInt16? {
        return number?.uint16Value
    }
    
    public var uint16Value: UInt16 {
        return numberValue.uint16Value
    }
    
    public var uint32: UInt32? {
        return number?.uint32Value
    }
    
    public var uint32Value: UInt32 {
        return numberValue.uint32Value
    }
    
    public var uint64: UInt64? {
        return number?.uint64Value
    }
    
    public var uint64Value: UInt64 {
        return numberValue.uint64Value
    }
    
    public var double: Double? {
        return number?.doubleValue
    }
    
    public var doubleValue: Double {
        return numberValue.doubleValue
    }
    
    public var float: Float? {
        return number?.floatValue
    }
    
    public var floatValue: Float {
        return numberValue.floatValue
    }
    
    public var bool: Bool? {
        if case .boolean(let boolean) = self {
            return boolean
        }
        else if case .number(let number) = self {
            return number.boolValue
        }
        else {
            return nil
        }
    }

    public var boolValue: Bool {
        if case .boolean(let boolean) = self {
            return boolean
        }
        else if case .number(let number) = self {
            return number.boolValue
        }
        else if case .string(let string) = self {
            return ["true", "yes", "1"].contains(string.lowercased())
        }
        else {
            return false
        }
    }

    public var string: String? {
        if case .string(let string) = self {
            return string
        }
        else {
            return nil
        }
    }

    public var stringValue: String {
        if case .string(let string) = self {
            return string
        }
        else if case .number(let number) = self {
            return number.stringValue
        }
        else if case .boolean(let boolean) = self {
            return String(boolean)
        }
        else {
            return String()
        }
    }

    public var null: NSNull? {
        if case .null = self {
            return NSNull()
        }
        else {
            return nil
        }
    }
    
    public func exists(withValue: Bool) -> Bool {
        if case .unknown = self {
            return false
        }
        else if case .null = self, withValue {
            return false
        }
        else {
            return true
        }
    }
    
    public func merged(with another: JsonElement) -> JsonElement {
        switch (self, another) {
        case let (.ordict(fst), .ordict(snd)):
            var result = fst
            snd.forEach { key, value in result[key] = value }
            return JsonElement(result)
        case let (.array(fst), .array(snd)):
            return JsonElement(fst + snd)
        default:
            return self
        }
    }
}
