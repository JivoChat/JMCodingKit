extension OrderedMap: Encodable where Key: Encodable, Value: Encodable {
    /// __inheritdoc__
    public func encode(to encoder: Encoder) throws {
        // Encode the ordered dictionary as an array of alternating key-value pairs.
        var container = encoder.unkeyedContainer()
        
//        try container.encode(swiftyTypeKey)
//        try container.encode(SwiftyTypeMarker.orderedMap.rawValue)
        
        for (key, value) in self {
            try container.encode(key)
            try container.encode(value)
        }
    }
}

extension OrderedMap: Decodable where Key: Decodable, Value: Decodable {
    /// __inheritdoc__
    public init(from decoder: Decoder) throws {
        // Decode the ordered dictionary from an array of alternating key-value pairs.
        self.init()
    
        var container = try decoder.unkeyedContainer()
        
//        guard try container.decode(String.self) == swiftyTypeKey else {
//            throw DecodingError.unkeyedContainerReachedEndBeforeValue(decoder.codingPath)
//        }
//
//        guard try container.decode(String.self) == SwiftyTypeMarker.orderedMap.rawValue else {
//            throw DecodingError.unkeyedContainerReachedEndBeforeValue(decoder.codingPath)
//        }
        
        while !container.isAtEnd {
            let key = try container.decode(Key.self)
            guard !container.isAtEnd else { throw DecodingError.unkeyedContainerReachedEndBeforeValue(decoder.codingPath) }
            let value = try container.decode(Value.self)
            
            self[key] = value
        }
    }
}
    
extension DecodingError {
    fileprivate static func unkeyedContainerReachedEndBeforeValue(_ codingPath: [CodingKey]) -> DecodingError {
        return DecodingError.dataCorrupted(
            DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "Unkeyed container reached end before value in key-value pair."
            )
        )
    }
}
