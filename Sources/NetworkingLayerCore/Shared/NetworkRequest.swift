//  Copyright © 2020 Kirby. All rights reserved.

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public enum HTTPMethod: String {
    case get
    case post
    case put
    case delete
    case patch

    var name: String {
        return rawValue.uppercased()
    }
}

public protocol NetworkRequest {
    var baseURL: URL? { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: NetworkQuery? { get }
    /// Can use dictionary or header to build
    @HeaderBuilder var headers: [Header]? { get }
    var body: NetworkBody? { get }
    var requestType: RequestType { get }
    var acceptableStatusCodes: [Int] { get }
    
    var acceptableEmptyResponseCodes: Set<Int> { get }

    // TODO: - I am not sure if this is optimal strategy for UI tests.
    /// Test url that will get used for unit/UI testing. By default the location is the environment variable of the object name.
    ///
    /// Get local url like e.g.
    ///
    ///     let url = Bundle.main.url(forResource: "foo", withExtension: "json")
    ///
    var testURL: URL? { get }
}

extension NetworkRequest {

    public func buildURLRequest() -> URLRequest? {

        guard let baseURL = baseURL else {
            return nil
        }

        var urlRequest = URLRequest(url: baseURL)

        addPath(path, to: &urlRequest)

        addMethod(method, to: &urlRequest)

        addQueryParameters(parameters, to: &urlRequest)

        addHeaders(headers, to: &urlRequest)

        addRequestBody(body, to: &urlRequest)

        return urlRequest
    }

    public var acceptableStatusCodes: [Int] {
        return Array(200..<300)
    }
    
    public var acceptableEmptyResponseCodes: Set<Int> {
        return [204, 205]
    }

    public var url: URL? {
        guard let baseURL = baseURL else {
            return nil
        }

        guard !path.isEmpty else {
            return baseURL
        }

        return baseURL.appendingPathComponent(path)
    }

    public var testURL: URL? {
        nil
    }
}

// MARK: - Private Helpers
private extension NetworkRequest {
    func addPath(_ path: String, to request: inout URLRequest) {
        guard !path.isEmpty else {
            return
        }

        let url = request.url?.appendingPathComponent(path)
        request.url = url
    }

    func addMethod(_ method: HTTPMethod, to request: inout URLRequest) {
        request.httpMethod = method.name
    }

    func addQueryParameters(_ query: NetworkQuery?, to request: inout URLRequest) {
        guard let query = query,
              let url = request.url else {
            return
        }

        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        
        let characterSet: CharacterSet = {
            switch query.encoding {
            case .standard:
                return CharacterSet.urlQueryAllowed
            case .custom(let set):
                return set
            }
        }()
        
        components?.percentEncodedQuery = query.parameters.compactMap {
            guard let key = $0.addingPercentEncoding(withAllowedCharacters: characterSet),
                  let value = String(describing: $1).addingPercentEncoding(withAllowedCharacters: characterSet) else {
                return nil
            }
            return key + "=" + value
        }.joined(separator: "&")
        
        request.url = components?.url
    }

    func addHeaders(_ headers: [Header]?, to request: inout URLRequest) {
        guard let headers = headers else {
            return
        }

        headers.forEach { request.setValue(String(describing: $0.value), forHTTPHeaderField: $0.key) }
    }

    func addRequestBody(_ body: NetworkBody?, to request: inout URLRequest) {
        guard let body = body else {
            return
        }

        if case .uploadMultipart = requestType {
            // Do not allow additional data for a multipart
            return
        }

        switch body.encoding {
        case .json:
            request.setValue(body.encoding.contentTypeValue, forHTTPHeaderField: "Content-Type")
            request.httpBody = body.data
        }
    }
}
