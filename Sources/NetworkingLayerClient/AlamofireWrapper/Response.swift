//  Copyright © 2020 Kirby. All rights reserved.

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public class NetworkResponse {
    public let statusCode: Int
    public let data: Data

    /// The original URLRequest for the response.
    /// The requesting URLRequest. This may not be the original url if there was a redirect.
    public let request: URLRequest?

    public let httpResponse: HTTPURLResponse?

    public init(statusCode: Int, data: Data, request: URLRequest?, httpResponse: HTTPURLResponse?) {
        self.statusCode = statusCode
        self.data = data
        self.request = request
        self.httpResponse = httpResponse
    }
}

class DownloadResponse: NetworkResponse {
    public let destinationURL: URL?

    public init(destinationURL: URL?, statusCode: Int, data: Data, request: URLRequest?, httpResponse: HTTPURLResponse?) {

        self.destinationURL = destinationURL

        super.init(statusCode: statusCode, data: data, request: request, httpResponse: httpResponse)
    }
}

/// A response with a already decoded object.
public class ResponseObject<Object>: NetworkResponse {
    public let object: Object

    public init(object: Object, statusCode: Int, data: Data, request: URLRequest?, httpResponse: HTTPURLResponse?) {
        self.object = object
        super.init(statusCode: statusCode, data: data, request: request, httpResponse: httpResponse)
    }
}
