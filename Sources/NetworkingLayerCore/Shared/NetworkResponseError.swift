//
//  NetworkResponseError.swift
//  
//
//  Created by Kevin Chen on 4/15/23.
//

import Foundation

// MARK: - Error
public enum NetworkResponseError: Error {
    case badRequest(message: String)
    
    case responseError(Error, response: NetworkResponse?)
        
    case responseParseError(Error, response: NetworkResponse)
    
    case unknown
    
    public var response: NetworkResponse? {
        switch self {
            
        case .badRequest:
            return nil
        case .responseError(_, let response):
            return response
        case .responseParseError(_, let response):
            return response
        case .unknown:
            return nil
        }
    }
}

extension NetworkResponseError: LocalizedError {
    public var errorDescription: String? {
        
        let genericMessage = NetworkingLayer.errorObject(for: GenericErrorResponse.self, from: self)?.message
        
        switch self {
        case .badRequest(let message):
            return message
        case .responseError(_, let response):
            if let message = genericMessage {
                return "\(message), code: \(response?.statusCode ?? 0)"
            } else {
                return "Networking Error, code: \(response?.statusCode ?? 0)"
            }
        case .responseParseError(_, let response):
            if let message = genericMessage {
                return "\(message), code: \(response.statusCode)"
            } else {
                return "Parsing Error, code: \(response.statusCode)"
            }
        case .unknown:
            return "Something Went Wrong"
        }
    }
}
