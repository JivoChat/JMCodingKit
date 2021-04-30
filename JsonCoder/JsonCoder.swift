//
//  JsonCoder.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 19.05.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation

public enum JsonElement: FlexibleElement, Equatable {
    public static func failure() -> JsonElement { .unknown }
    case ordict(OrderedMap<String, JsonElement>)
    case array([JsonElement])
    case string(String)
    case number(NSNumber)
    case boolean(Bool)
    case null
    case unknown
}

public struct JsonCodingOptions: FlexibleCodingOptions {
    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    public func verboseLogging() -> Bool { contains(.verbose) }
    public static let unquotedKey = JsonCodingOptions(rawValue: 1 << 1)
    public static let pretty = JsonCodingOptions(rawValue: 1 << 2)
    public static let verbose = JsonCodingOptions(rawValue: 1 << 3)
}

public enum JsonDecodingError {
    case failedDecoding
}

public final class JsonCoder: FlexibleCoder<JsonElement, JsonCodingOptions> {
    private let elementCoders: [FlexibleElementCoder]
    
    public override init() {
        elementCoders = [
            JsonStringCoder(), JsonNumberCoder(), JsonBooleanCoder(),
            JsonOrdictCoder(), JsonArrayCoder(),
            JsonNullCoder()
        ]
    }
    
    public override var coders: [FlexibleElementCoder] {
        return elementCoders
    }

    public override func decode(raw: String, options: JsonCodingOptions = []) -> JsonElement? {
        super.decode(raw: raw.trimmingCharacters(in: .whitespacesAndNewlines), options: options)
    }
}
