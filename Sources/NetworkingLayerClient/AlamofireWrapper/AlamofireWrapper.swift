//  Copyright © 2020 Kirby. All rights reserved.
//

import Alamofire
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public typealias DownloadDestination = Alamofire.DownloadRequest.Destination

/// A simple wrapper around Alamofire to abstract out the request building from client.
public struct AlamofireWrapper: Networkable {
    
    private let manager: AlamofireWrapperManager
    private let handler: AlamofireWrapperHandler

    #if !(os(watchOS) || os(Linux) || os(Windows))
    public var isConnectedToInternet: Bool {
        return Self.isConnectedToInternet
    }
    
    
    public static var isConnectedToInternet: Bool {
        return NetworkReachabilityManager()?.isReachable ?? false
    }
    #endif

    public init(manager: AlamofireWrapperManager = AlamofireWrapper.defaultManager,
                handler: AlamofireWrapperHandler = AlamofireWrapper.defaultHandler) {
        self.manager = manager
        self.handler = handler
    }
    
    // One problem is cancelling a task. Might want a wrapper that creates a task then sends.
    public func send<Request: NetworkRequest>(request: Request,
                                              callbackQueue: DispatchQueue = .main,
                                              progressHandler: ProgressHandler? = nil) async throws -> NetworkResponse {
        guard let urlRequest = request.buildURLRequest() else {
            throw AlamofireWrapperError.badRequest(message: "Bad URL Request")
        }
        
        switch request.requestType {
        case .requestData:
            return try await handler.handleDataRequest(for: urlRequest,
                                                       manager: manager,
                                                       request: request,
                                                       callbackQueue: callbackQueue,
                                                       progressHandler: progressHandler)
            
        case .download(let destination):
            return try await handler.handleDownloadRequest(for: urlRequest,
                                                           manager: manager,
                                                           request: request,
                                                           callbackQueue: callbackQueue,
                                                           destination: destination,
                                                           progressHandler: progressHandler)
            
            
        case .uploadMultipart(let body):
            return try await handler.handleUploadMultipart(for: urlRequest,
                                                           multipartBody: body,
                                                           manager: manager,
                                                           request: request,
                                                           callbackQueue: callbackQueue,
                                                           usingThreshold: MultipartFormData.encodingMemoryThreshold,
                                                           uploadProgressHandler: progressHandler)
        }
    }
    
    /// Send a request to expect data from response.
    /// - Parameter callbackQueue: nil will default to main.
    @discardableResult
    public func send<Request: NetworkRequest>(request: Request,
                                              callbackQueue: DispatchQueue = .main,
                                              progressHandler: ProgressHandler? = nil,
                                              completion: @escaping (Swift.Result<NetworkResponse, AlamofireWrapperError>) -> Void) -> AlamofireWrapperBaseRequest? {
        
        guard let urlRequest = request.buildURLRequest() else {
            completion(.failure(.badRequest(message: "Bad URL Request")))
            return nil
        }
        
        switch request.requestType {
        case .requestData:
            return handler.handleDataRequest(for: urlRequest,
                                             manager: manager,
                                             request: request,
                                             callbackQueue: callbackQueue,
                                             progressHandler: progressHandler,
                                             completion: completion)
            
        case .download(let destination):
            return handler.handleDownloadRequest(for: urlRequest,
                                                 manager: manager,
                                                 request: request,
                                                 callbackQueue: callbackQueue,
                                                 destination: destination,
                                                 progressHandler: progressHandler,
                                                 completion: completion)
            
        case .uploadMultipart(let body):
            return handler.handleUploadMultipart(for: urlRequest,
                                                 multipartBody: body,
                                                 manager: manager,
                                                 request: request,
                                                 callbackQueue: callbackQueue,
                                                 usingThreshold: MultipartFormData.encodingMemoryThreshold,
                                                 uploadProgressHandler: progressHandler,
                                                 completion: completion)
        }
    }
    
    // MARK: Codable Requests
    /// Makes a network request with any codable response object and will return it.
    @discardableResult
    public func send<Request: CodableRequest>(
        codableRequest: Request,
        callbackQueue: DispatchQueue = .main,
        progressHandler: ProgressHandler? = nil,
        completion: @escaping (Swift.Result<ResponseObject<Request.Response>, AlamofireWrapperError>) -> Void)
    -> AlamofireWrapperBaseRequest? {
        
        send(request: codableRequest,
             callbackQueue: callbackQueue,
             progressHandler: progressHandler) { (result) in
            
            decode(result: result, completion: completion)
        }
    }
    
    /// Makes a network request with any codable response object and will return it.
    
    @discardableResult
    public func send<Request: CodableRequest>(
        codableRequest: Request,
        callbackQueue: DispatchQueue = .main,
        progressHandler: ProgressHandler? = nil) async throws -> ResponseObject<Request.Response> {
            
            let response = try await send(request: codableRequest,
                                          callbackQueue: callbackQueue,
                                          progressHandler: progressHandler)
            
            return try decodeSuccess(from: response)
        }
    
    @discardableResult
    public func send<Request: NetworkRequest, C: Decodable>(
        request: Request,
        codableType: C.Type,
        callbackQueue: DispatchQueue = .main,
        progressHandler: ProgressHandler? = nil) async throws
    -> ResponseObject<C> {
        
        let response = try await send(request: request,
                                      callbackQueue: callbackQueue,
                                      progressHandler: progressHandler)
        
        return try decodeSuccess(from: response)
    }
    
    @discardableResult
    public func send<Request: NetworkRequest, C: Decodable>(
        request: Request,
        codableType: C.Type,
        callbackQueue: DispatchQueue = .main,
        progressHandler: ProgressHandler? = nil,
        completion: @escaping (Swift.Result<ResponseObject<C>, AlamofireWrapperError>) -> Void)
    -> AlamofireWrapperBaseRequest? {
        
        send(request: request,
             callbackQueue: callbackQueue,
             progressHandler: progressHandler) { (result) in
            
            decode(result: result, completion: completion)
        }
    }
    
    public func cancelAll() {
        manager.session.getAllTasks { (tasks) in
            tasks.forEach { $0.cancel() }
        }
    }
    
    private func decodeResult<C: Decodable>(
        result: Swift.Result<NetworkResponse, AlamofireWrapperError>) -> Swift.Result<ResponseObject<C>, AlamofireWrapperError> {
            
            switch result {
            case .success(let response):
                do {
                    return .success(try decodeSuccess(from: response))
                } catch {
                    return .failure(.responseParseError(error, response: response))
                }
            case .failure(let error):
                return .failure(error)
            }
        }
    
    private func decodeSuccess<C: Decodable>(from response: NetworkResponse) throws -> ResponseObject<C> {
        let decoder = JSONDecoder()
        let object = try decoder.decode(C.self, from: response.data)
        let response = ResponseObject(object: object,
                                      statusCode: response.statusCode,
                                      data: response.data,
                                      request: response.request,
                                      httpResponse: response.httpResponse)
        
        return response
    }
    
    private func decode<C: Decodable>(
        result: Swift.Result<NetworkResponse, AlamofireWrapperError>,
        completion: @escaping (Swift.Result<ResponseObject<C>, AlamofireWrapperError>) -> Void) {
            
            let decodedResult: Swift.Result<ResponseObject<C>, AlamofireWrapperError> = decodeResult(result: result)
            completion(decodedResult)
        }
}

extension AlamofireWrapper {
    public static let defaultHandler: AlamofireWrapperHandler = {
        return AlamofireWrapperDefaultHandler()
    }()
    
    public static let defaultManager: AlamofireWrapperManager = {
        return Session.default
    }()
}

// MARK: - Error
public enum AlamofireWrapperError: Error {
    case badRequest(message: String)
    
    case responseError(Error, response: NetworkResponse?)
    
    case alamofireError(AFError, response: NetworkResponse?)
    
    case responseParseError(Error, response: NetworkResponse)
    
    case unknown
    
    public var response: NetworkResponse? {
        switch self {
            
        case .badRequest:
            return nil
        case .responseError(_, let response):
            return response
        case .alamofireError(_, let response):
            return response
        case .responseParseError(_, let response):
            return response
        case .unknown:
            return nil
        }
    }
}

extension AlamofireWrapperError: LocalizedError {
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
        case .alamofireError(_, let response):
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
