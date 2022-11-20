//
//  File.swift
//  
//
//  Created by Kevin Chen on 11/20/22.
//

import Foundation

@resultBuilder
public struct HeaderBuilder {
    public static func buildBlock(_ components: [Header]...) -> [Header] {
        components.flatMap { $0 }
    }
    
    public static func buildExpression(_ expression: Header) -> [Header] {
        [expression]
    }
    
    public static func buildExpression(_ expression: [Header]) -> [Header] {
        expression
    }
    
    public static func buildExpression(_ expression: [String: Any]) -> [Header] {
        expression.compactMap { Header(key: $0.key, value: $0.value) }
    }
    
    public static func buildOptional(_ component: [Header]?) -> [Header] {
        component ?? []
    }
    
    public static func buildEither(first component: [Header]) -> [Header] {
        component
    }
    
    public static func buildEither(second component: [Header]) -> [Header] {
        component
    }
    
    public static func buildArray(_ components: [[Header]]) -> [Header] {
        components.flatMap { $0 }
    }
}

public struct Header {
    let key: String
    let value: Any
}

// MARK: - Standard Headers
extension HeaderBuilder {
    public static func authorization(token: String) -> Header {
        return Header(key: "Authorization", value: token)
    }
}
