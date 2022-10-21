// Copyright © 2020 Gosite. All rights reserved.

import Foundation
@testable import NetworkingLayerClient

enum MockStandardRequest: NetworkRequest {
    case validRequest
    case validRequestWithPath
    case invalidRequest
    case validRequestWithQueryParams
    case validRequestWithHeaders
    case validRequestWithJSONBody
    case validDownload
    case validMultipart
    
    var baseURL: URL? {
        switch self {
            
        case .validRequest:
            return URL(string: "https://mockurlawfgafwafawf.com")
        case .validRequestWithPath:
            return URL(string: "https://mockurlawfgafwafawf.com")
        case .invalidRequest:
            return URL(string: "")
        case .validRequestWithQueryParams:
            return URL(string: "https://mockurlawfgafwafawf.com")
        case .validRequestWithHeaders:
            return URL(string: "https://mockurlawfgafwafawf.com")
        case .validRequestWithJSONBody:
            return URL(string: "https://mockurlawfgafwafawf.com")
        case .validDownload:
            return URL(string: "https://mockurlawfgafwafawf.com")
        case .validMultipart:
            return URL(string: "https://mockurlawfgafwafawf.com")
        }
    }
    
    var path: String {
        switch self {
            
        case .validRequest:
            return ""
        case .validRequestWithPath:
            return "/foo"
        case .invalidRequest:
            return ""
        case .validRequestWithQueryParams:
            return ""
        case .validRequestWithHeaders:
            return ""
        case .validRequestWithJSONBody:
            return ""
        case .validDownload:
            return ""
        case .validMultipart:
            return ""
        }
    }
    
    var method: HTTPMethod {
        switch self {
            
        case .validRequest:
            return .get
        case .validRequestWithPath:
            return .get
        case .invalidRequest:
            return .get
        case .validRequestWithQueryParams:
            return .get
        case .validRequestWithHeaders:
            return .get
        case .validRequestWithJSONBody:
            return .get
        case .validDownload:
            return .get
        case .validMultipart:
            return .post
        }
    }
    
    var parameters: [String : Any]? {
        switch self {
        case .validRequest:
            return nil
        case .validRequestWithPath:
            return nil
        case .invalidRequest:
            return nil
        case .validRequestWithQueryParams:
            return ["foo": "bar", "fooz": "barz"]
        case .validRequestWithHeaders:
            return nil
        case .validRequestWithJSONBody:
            return nil
        case .validDownload:
            return nil
        case .validMultipart:
            return nil
        }
    }
    
    var headers: [String : Any]? {
        switch self {
        case .validRequest:
            return nil
        case .validRequestWithPath:
            return nil
        case .invalidRequest:
            return nil
        case .validRequestWithQueryParams:
            return nil
        case .validRequestWithHeaders:
            return ["foo": "bar", "fooz": "barz"]
        case .validRequestWithJSONBody:
            return nil
        case .validDownload:
            return nil
        case .validMultipart:
            return nil
        }
    }
    
    var body: NetworkBody? {
        switch self {
        case .validRequest:
            return nil
        case .validRequestWithPath:
            return nil
        case .invalidRequest:
            return nil
        case .validRequestWithQueryParams:
            return nil
        case .validRequestWithHeaders:
            return nil
        case .validRequestWithJSONBody:
            let data =
                """
                    {"foo": "bar"}
                """
                    .data(using: .utf8)
            
            
            return NetworkBody(data: data!, encoding: .json)
        case .validDownload:
            return nil
        case .validMultipart:
            return nil
        }
    }
    
    var requestType: RequestType {
        switch self {
        case .validRequest:
            return .requestData
        case .validRequestWithPath:
            return .requestData
        case .invalidRequest:
            return .requestData
        case .validRequestWithQueryParams:
            return .requestData
        case .validRequestWithHeaders:
            return .requestData
        case .validRequestWithJSONBody:
            return .requestData
        case .validDownload:
            return .download(nil)
        case .validMultipart:
            let body1 = MultipartData(data: Data(), name: "foo", fileName: "foo.png", mimeType: "image/png")
            return .uploadMultipart(body: [body1])
        }
    }
}

struct Foo: Codable, Equatable {
    let foo: String
    let fooz: String
}

struct MockCodableRequest: CodableRequest {
    typealias Response = Foo
    
    var baseURL: URL? {
        return URL(string: "https://mockurlawfgafwafawf.com")
    }
    
    var path: String {
        return ""
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var parameters: [String : Any]?
    
    var headers: [String : Any]?
    
    var body: NetworkBody?
    
    var requestType: RequestType {
        .requestData
    }
}
