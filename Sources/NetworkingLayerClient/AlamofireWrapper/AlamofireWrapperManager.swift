// Created by Kirby on 8/3/20.
// Copyright © 2020 Kirby. All rights reserved.

import Alamofire
import Foundation

protocol AlamofireWrapperManager {
    var session: URLSession { get }

    // These map the data requests to the wrapper
    func request(_ urlRequest: URLRequestConvertible) -> AlamofireWrapperDataRequest
    func download(_ urlRequest: URLRequestConvertible,
                  to destination: DownloadRequest.Destination?) -> AlamofireWrapperDownloadRequest
    func upload(
        multipartFormData: @escaping (MultipartFormData) -> Void,
        usingThreshold encodingMemoryThreshold: UInt64,
        with urlRequest: URLRequestConvertible) -> AlamofireWrapperUploadRequest

}

/// The base request that is returned to client
public protocol AlamofireWrapperBaseRequest {
    var task: URLSessionTask? { get }
}

/// Just an intermediate for requests that have the same methods
protocol AlamofireWrapperRequest: AlamofireWrapperBaseRequest {

    func validate<S: Sequence>(statusCode acceptableStatusCodes: S) -> Self where S.Iterator.Element == Int
    func downloadProgress(queue: DispatchQueue,
                          closure: @escaping Alamofire.Request.ProgressHandler) -> Self
}

protocol AlamofireWrapperDataRequest: AlamofireWrapperRequest {
    @discardableResult
    func responseData(queue: DispatchQueue,
                      dataPreprocessor: DataPreprocessor,
                      emptyResponseCodes: Set<Int>,
                      emptyRequestMethods: Set<Alamofire.HTTPMethod>,
                      completionHandler: @escaping (AFDataResponse<Data>) -> Void) -> Self
    
    func serializingData(automaticallyCancelling shouldAutomaticallyCancel: Bool,
                         dataPreprocessor: DataPreprocessor,
                         emptyResponseCodes: Set<Int>,
                         emptyRequestMethods: Set<Alamofire.HTTPMethod>) -> DataTask<Data>
}

protocol AlamofireWrapperDownloadRequest: AlamofireWrapperRequest {
    func response(queue: DispatchQueue,
                  completionHandler: @escaping (AFDownloadResponse<URL?>) -> Void) -> Self
    
    func serializingData(automaticallyCancelling shouldAutomaticallyCancel: Bool,
                         dataPreprocessor: DataPreprocessor,
                         emptyResponseCodes: Set<Int>,
                         emptyRequestMethods: Set<Alamofire.HTTPMethod>) -> DownloadTask<Data>
}

protocol AlamofireWrapperUploadRequest: AlamofireWrapperDataRequest {
    @discardableResult
    func uploadProgress(queue: DispatchQueue, closure: @escaping Request.ProgressHandler) -> Self
    
    @discardableResult
    func responseData(queue: DispatchQueue,
                      dataPreprocessor: DataPreprocessor,
                      emptyResponseCodes: Set<Int>,
                      emptyRequestMethods: Set<Alamofire.HTTPMethod>,
                      completionHandler: @escaping (AFDataResponse<Data>) -> Void) -> Self
}

// MARK: - Alamofire conformance
extension Session: AlamofireWrapperManager {
    func request(_ urlRequest: URLRequestConvertible) -> AlamofireWrapperDataRequest {

        let dataRequest: DataRequest = request(urlRequest)
        return dataRequest
    }

    func download(_ urlRequest: URLRequestConvertible, to destination: DownloadRequest.Destination?) -> AlamofireWrapperDownloadRequest {
        let request: DownloadRequest = download(urlRequest, to: destination)

        return request
    }
    
    func upload(multipartFormData: @escaping (MultipartFormData) -> Void,
                usingThreshold encodingMemoryThreshold: UInt64,
                with urlRequest: URLRequestConvertible) -> AlamofireWrapperUploadRequest {
        let request: UploadRequest = upload(multipartFormData: multipartFormData,
                                            with: urlRequest,
                                            usingThreshold: encodingMemoryThreshold)
                
        return request
    }
}

extension Request: AlamofireWrapperBaseRequest {

}

extension DataRequest: AlamofireWrapperDataRequest {

}

extension DownloadRequest: AlamofireWrapperDownloadRequest {

}

extension UploadRequest: AlamofireWrapperUploadRequest {

}
