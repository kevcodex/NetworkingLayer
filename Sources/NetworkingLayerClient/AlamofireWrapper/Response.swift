//  Copyright © 2020 Kirby. All rights reserved.

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public class NetworkResponse {
    let statusCode: Int
    let data: Data

    /// The original URLRequest for the response.
    /// The requesting URLRequest. This may not be the original url if there was a redirect.
    let request: URLRequest?

    let httpResponse: HTTPURLResponse?

    init(statusCode: Int, data: Data, request: URLRequest?, httpResponse: HTTPURLResponse?) {
        self.statusCode = statusCode
        self.data = data
        self.request = request
        self.httpResponse = httpResponse
    }
}

class DownloadResponse: NetworkResponse {
    let destinationURL: URL?

    init(destinationURL: URL?, statusCode: Int, data: Data, request: URLRequest?, httpResponse: HTTPURLResponse?) {

        self.destinationURL = destinationURL

        super.init(statusCode: statusCode, data: data, request: request, httpResponse: httpResponse)
    }
}

/// A response with a already decoded object.
public class ResponseObject<Object>: NetworkResponse {
    let object: Object

    init(object: Object, statusCode: Int, data: Data, request: URLRequest?, httpResponse: HTTPURLResponse?) {
        self.object = object
        super.init(statusCode: statusCode, data: data, request: request, httpResponse: httpResponse)
    }
}
