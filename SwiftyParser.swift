//
//  SwiftyParser.swift
//  SwiftyParser
//
//  Created by Matthew Cheok on 19/6/15.
//  Modified by Stan Potemkin on 13/05/20.
//  Copyright © 2015 matthewcheok. All rights reserved.
//

import Foundation

private enum InternalError: Error {
    case CannotFindCharacter(character: Character)
    case MalformedString
}

extension Collection {
    fileprivate func throwingMap<T>(transform: (Iterator.Element) throws -> T) throws -> [T] {
        var ts: [T] = []
        for x in self {
            ts.append(try transform(x))
        }
        return ts
    }
}

extension String {
    fileprivate func splitByCharacter(_ character: Character) throws -> [String] {
        if self.isEmpty {
            return []
        }
        
        var results: [String] = []
        var arrayCount = 0
        var objectCount = 0
        var stringOpen = false
        
        var start = startIndex, end = startIndex
        while end < endIndex {
            let c = self[end]
            
            switch c {
            case "\"":
                stringOpen = !stringOpen
                
            case "[":
                arrayCount += 1
                
            case "]":
                arrayCount -= 1
                
            case "{":
                objectCount += 1
                
            case "}":
                objectCount -= 1
                
            default:
                ()
            }
            
            if c == character
                && !stringOpen
                && arrayCount == 0
                && objectCount == 0 {
                    results.append(substring(with: start ..< end))
                    start = index(after: end)
            }
            
            if arrayCount < 0 || objectCount < 0 {
                throw InternalError.MalformedString
            }
            
            end = index(after: end)
        }
        
        results.append(substring(with: start ..< end))
        return results
    }
    
    fileprivate func matchesFirstAndLastCharacters(_ first: Character, _ last: Character) -> Bool {
        guard let f = self.first else {
            return false
        }
        
        guard let l = self.last else {
            return false
        }
        
        return f == first && l == last
    }
    
    fileprivate func trimFirstAndLastCharacters() -> String {
        if index(after: startIndex) < endIndex {
            return substring(with: index(after: startIndex) ..< index(before: endIndex))
        }
        else {
            return String()
        }
    }
}

public struct SwiftyParser {
    typealias JSONObject = OrderedMap<String, Any>
    typealias JSONArray = [Any]
    
    struct JSONNull {}
    
    enum DecodeError: Error {
        case MalformedJSON
    }
    
    enum EncodeError: Error {
        case IncompatibleType
    }
    
    static func decode(_ JSON: String) throws -> Any {
        let trimmed = JSON.trimWhiteSpaceAndNewline()
        
        // empty
        if trimmed.isEmpty {
            throw DecodeError.MalformedJSON
        }
            
            // object
        else if trimmed.matchesFirstAndLastCharacters("{", "}") {
            // split by key, value pairs
            let pairs: [String]
            do {
                pairs = try trimmed.trimFirstAndLastCharacters().splitByCharacter(",")
            }
            catch {
                throw DecodeError.MalformedJSON
            }
            
            var object = OrderedMap<String, Any>()
            for pair in pairs {
                // split into tokens
                let tokens: [String]
                do {
                    tokens = try pair.trimWhiteSpaceAndNewline().splitByCharacter(":")
                }
                catch {
                    throw DecodeError.MalformedJSON
                }
                
                // pair must have exactly 2 tokens
                guard tokens.count == 2 else {
                    throw DecodeError.MalformedJSON
                }
                
                // first token in pair must be a string
                guard tokens[0].matchesFirstAndLastCharacters("\"", "\"") else {
                    throw DecodeError.MalformedJSON
                }
                
                let key = tokens[0].trimFirstAndLastCharacters()
                if let value = try? decode(tokens[1]) {
                    object.updateValue(value, forKey: key)
                }
            }
            
            return object
        }
            
            // array
        else if trimmed.matchesFirstAndLastCharacters("[", "]") {
            // split into tokens
            let tokens: [String]
            do {
                tokens = try trimmed.trimFirstAndLastCharacters().splitByCharacter(",")
            }
            catch {
                throw DecodeError.MalformedJSON
            }
            
            return try tokens.throwingMap { try decode($0) }
        }
            
            // boolean literals
        else if trimmed == "true" {
            return true
        }
        else if trimmed == "false" {
            return false
        }
            
            // integer
        else if let number = Int(trimmed) {
            return number
        }
            
            // double
        else if let number = Double(trimmed) {
            return number
        }
            
            // null
        else if trimmed == "null" {
            return JSONNull()
        }
            
        // string
        else if trimmed.matchesFirstAndLastCharacters("\"", "\"") {
            return trimmed.trimFirstAndLastCharacters().replacingOccurrences(of: "\\\"", with: "\"")
        }
            
        // string
        else {
            return trimmed
        }
    }
    
    static func encode(_ JSON: Any, prettyPrint: Bool = false) throws -> String {
        if prettyPrint {
            let result = try _encodePretty(JSON)
            return result.joined(separator: "\n")
        }
        else {
            return try _encode(JSON)
        }
    }
    
    private static func _flattenWithCommas(_ array: [[String]]) -> [String] {
        var result = [String]()
        for (index, sub) in array.enumerated() {
            if index < array.count-1 {
                let last = sub.count-1
                result.append(contentsOf: sub[0..<last])
                result.append(sub[last] + ", ")
            }
            else {
                result.append(contentsOf: sub)
            }
        }
        return result
    }
    
    private static func _encodePretty(_ JSON: Any) throws -> [String] {
        let kIndentationString = "   "
        
        // object
        if let object = JSON as? JSONObject {
            let result = try object.throwingMap {
                (key, value) -> [String] in
                let encoded = try _encodePretty(value)
                return ["\"\(key)\": " + encoded[0]] + encoded[1..<encoded.count]
            }
            let indented = _flattenWithCommas(result).map { kIndentationString + $0 }
            return ["{"] + indented + ["}"]
        }
            
            // array
        else if let array = JSON as? JSONArray {
            // nested array of lines
            let result = try array.throwingMap { try _encodePretty($0) }
            let indented = _flattenWithCommas(result).map { kIndentationString + $0 }
            return ["["] + indented + ["]"]
        }
            
            // others
        else {
            return [try _encode(JSON)]
        }
    }
    
    private static func _encode(_ JSON: Any) throws -> String {
        // object
        if let object = JSON as? JSONObject {
            let result = try object.throwingMap {
                (key, value) in
                return "\"\(key)\": " + (try _encode(value))
            }
            return "{" + result.joined(separator: ",") + "}"
        }
            
            // array
        else if let array = JSON as? JSONArray {
            let result = try array.throwingMap { try _encode($0) }
            return "[" + result.joined(separator: ", ") + "]"
        }
            
            // bool
        else if let bool = JSON as? Bool {
            return bool ? "true" : "false"
        }
            
            // integer
        else if let int = JSON as? Int {
            return int.description
        }
            
            // double
        else if let double = JSON as? Double {
            return double.description
        }
            
            // null
        else if JSON is JSONNull {
            return "null"
        }
            
            // string
        else if let string = JSON as? String {
            return string
        }
            
        else {
            throw EncodeError.IncompatibleType
        }
    }
}

extension Character {
    public static var newlineCharacterSet: Set<Character> {
        return ["\u{000A}", "\u{000B}", "\u{000C}", "\u{000D}", "\u{0085}"]
    }
    
    public static var whiteSpaceCharacterSet: Set<Character> {
        return ["\u{0020}", "\u{0009}"]
    }
    
    public static var whiteSpaceAndNewlineCharacterSet: Set<Character> {
        return self.newlineCharacterSet.union(self.whiteSpaceCharacterSet)
    }
}

extension String {
    public func trimCharactersInSet(_ characterSet: Set<Character>) -> String {
        var startIndex = self.startIndex
        var endIndex = self.endIndex
        
        while startIndex < endIndex && characterSet.contains(self[startIndex]) {
            startIndex = index(after: startIndex)
        }
        
        while endIndex > startIndex && characterSet.contains(self[index(before: endIndex)]) {
            endIndex = index(before: endIndex)
        }
        
        return substring(with: startIndex..<endIndex)
    }
    
    public func trimWhiteSpaceAndNewline() -> String {
        return trimCharactersInSet(Character.whiteSpaceAndNewlineCharacterSet)
    }
}
