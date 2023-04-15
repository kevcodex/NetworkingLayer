// Created by Kirby on 8/4/20.
// Copyright © 2020 Kirby. All rights reserved.

import Foundation

public protocol NetworkTask {
    func cancel()
}

public protocol Networkable {
    func send<Request: NetworkRequest>(request: Request,
                                       callbackQueue: DispatchQueue,
                                       progressHandler: ProgressHandler?) async throws -> NetworkResponse
    
    @discardableResult
    func send<Request: NetworkRequest>(
        request: Request,
        callbackQueue: DispatchQueue,
        progressHandler: ProgressHandler?,
        completion: @escaping (Swift.Result<NetworkResponse, AlamofireWrapperError>) -> Void) -> NetworkTask?
    
    @discardableResult
    func send<Request: CodableRequest>(
        codableRequest: Request,
        callbackQueue: DispatchQueue,
        progressHandler: ProgressHandler?,
        completion: @escaping (Swift.Result<ResponseObject<Request.Response>, AlamofireWrapperError>) -> Void)
    -> NetworkTask?
    
    @discardableResult
    func send<Request: NetworkRequest, C: Decodable>(
        request: Request,
        codableType: C.Type,
        callbackQueue: DispatchQueue,
        progressHandler: ProgressHandler?)
    async throws -> ResponseObject<C>
    
    @discardableResult
    func send<Request: NetworkRequest, C: Decodable>(
        request: Request,
        codableType: C.Type,
        callbackQueue: DispatchQueue,
        progressHandler: ProgressHandler?,
        completion: @escaping (Swift.Result<ResponseObject<C>, AlamofireWrapperError>) -> Void)
    -> NetworkTask?
    
    func cancelAll()
}

/// The layer that determines where to get data.
/// If unit testing it will use test handler which sends back test data.
/// In future, if we cahce maybe get from offline storage.
public struct NetworkingLayer {
    
    let wrapper: Networkable
    
    public init(wrapper: Networkable = AlamofireWrapper()) {
        self.wrapper = wrapper
    }
    
    /// Send a request to expect data from response.
    /// - Parameter callbackQueue: nil will default to main.
    @discardableResult
    public func send<Request: NetworkRequest>(request: Request,
                                              callbackQueue: DispatchQueue = .main,
                                              progressHandler: ProgressHandler? = nil,
                                              completion: @escaping (Swift.Result<NetworkResponse, AlamofireWrapperError>) -> Void) -> NetworkTask? {
        wrapper.send(request: request, callbackQueue: callbackQueue, progressHandler: progressHandler, completion: completion)
    }
    
    /// Send a request to expect data from response.
    /// - Parameter callbackQueue: nil will default to main.
    @discardableResult
    public func send<Request: NetworkRequest>(request: Request,
                                              callbackQueue: DispatchQueue = .main,
                                              progressHandler: ProgressHandler? = nil) async throws ->  NetworkResponse {
        try await wrapper.send(request: request, callbackQueue: callbackQueue, progressHandler: progressHandler)
    }
    
    /// Makes a network request with any codable response object and will return it.
    @discardableResult
    public func send<Request: CodableRequest>(
        codableRequest: Request,
        callbackQueue: DispatchQueue = .main,
        progressHandler: ProgressHandler? = nil,
        completion: @escaping (Swift.Result<ResponseObject<Request.Response>, AlamofireWrapperError>) -> Void)
    -> NetworkTask? {
        wrapper.send(codableRequest: codableRequest, callbackQueue: callbackQueue, progressHandler: progressHandler, completion: completion)
    }
    
    @discardableResult
    public func send<Request: NetworkRequest, C: Decodable>(
        request: Request,
        codableType: C.Type,
        callbackQueue: DispatchQueue = .main,
        progressHandler: ProgressHandler? = nil,
        completion: @escaping (Swift.Result<ResponseObject<C>, AlamofireWrapperError>) -> Void)
    -> NetworkTask? {
        
        wrapper.send(request: request, codableType: codableType, callbackQueue: callbackQueue, progressHandler: progressHandler, completion: completion)
    }
    
    @discardableResult
    public func send<Request: NetworkRequest, C: Decodable>(
        request: Request,
        codableType: C.Type,
        callbackQueue: DispatchQueue = .main,
        progressHandler: ProgressHandler? = nil)
    async throws -> ResponseObject<C> {
        
        try await wrapper.send(request: request, codableType: codableType, callbackQueue: callbackQueue, progressHandler: progressHandler)
    }
    
    public func cancelAll() {
        wrapper.cancelAll()
    }
}

extension NetworkingLayer {
    
    public static func errorObject<T: Decodable>(for type: T.Type? = nil, from error: AlamofireWrapperError) -> T? {
        guard let data = error.response?.data else {
            return nil
        }
        
        do {
            let errorResponse = try JSONDecoder().decode(T.self, from: data)
            return errorResponse
        } catch {
            return nil
        }
    }
}
