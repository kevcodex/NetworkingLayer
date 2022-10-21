//  Copyright © 2020 Kirby. All rights reserved.

import Foundation

public struct NetworkBody {

    let data: Data

    let encoding: NetworkEncodingType

    public init(data: Data, encoding: NetworkEncodingType) {
        self.data = data
        self.encoding = encoding
    }

    public init(dictionary: [String: Any], encoding: NetworkEncodingType, options: JSONSerialization.WritingOptions = []) throws {

        var data: Data

        switch encoding {
        case .json:
            data = try JSONSerialization.data(withJSONObject: dictionary, options: options)
        }

        self.init(data: data, encoding: encoding)
    }

    public init<E: Encodable>(object: E, encoding: NetworkEncodingType, encoder: JSONEncoder = JSONEncoder()) throws {
        let data = try encoder.encode(object)
        self.init(data: data, encoding: encoding)
    }
}

struct NetworkQuery {
    let parameters: [String: Any]
    let encoding: QueryEncodingType
    
    enum QueryEncodingType {
        case standard
        case custom
    }
}
