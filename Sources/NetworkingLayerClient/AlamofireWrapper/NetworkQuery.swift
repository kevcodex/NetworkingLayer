//
//  NetworkQuery.swift
//  
//
//  Created by Kevin Chen on 10/20/22.
//

import Foundation

public struct NetworkQuery {

    public let parameters: [String: Any]
    public let encoding: QueryEncodingType
    
    public init(parameters: [String : Any], encoding: NetworkQuery.QueryEncodingType = .standard) {
        self.parameters = parameters
        self.encoding = encoding
    }
    
    public enum QueryEncodingType {
        case standard
        case custom(CharacterSet)
    }
}
