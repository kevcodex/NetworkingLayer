// Copyright © 2020 Gosite. All rights reserved.

import Foundation

import XCTest
@testable import NetworkingLayerCore

final class RequestTests: XCTestCase {
    
    func testInvalidURL_ReturnsNil() {
        let request = MockStandardRequest.invalidRequest
        
        XCTAssertNil(request.url)
    }
    
    func testBuildingInvalidURL_ReturnsNil() {
        let request = MockStandardRequest.invalidRequest
        
        let urlRequest = request.buildURLRequest()
                
        XCTAssertNil(urlRequest?.url)
    }
    
    func testFullURL_WithoutPath_IsSuccessful() {
        let request = MockStandardRequest.validRequest
        
        let expectedURL = URL(string: "https://mockurlawfgafwafawf.com")
        
        XCTAssertTrue(request.url == expectedURL)
    }
    
    func testBuildingURL_WithoutPath_IsSuccessful() {
        let request = MockStandardRequest.validRequest
        
        let urlRequest = request.buildURLRequest()
        
        let expectedURL = URL(string: "https://mockurlawfgafwafawf.com")
        
        XCTAssertTrue(urlRequest?.url == expectedURL)
    }
    
    func testFullURL_WithPath_IsSuccessful() {
        let request = MockStandardRequest.validRequestWithPath
        
        let expectedURL = URL(string: "https://mockurlawfgafwafawf.com/foo")
        
        XCTAssertTrue(request.url == expectedURL)
    }
    
    func testBuildingURL_WithPath_IsSuccessful() {
        let request = MockStandardRequest.validRequestWithPath
        
        let urlRequest = request.buildURLRequest()
        
        let expectedURL = URL(string: "https://mockurlawfgafwafawf.com/foo")
        
        XCTAssertTrue(urlRequest?.url == expectedURL)
    }
    
    func testBuildingURL_WithQueryParams_IsSuccessful() {
        let request = MockStandardRequest.validRequestWithQueryParams
        
        let urlRequest = request.buildURLRequest()
        
        let expectedQueries = [URLQueryItem(name: "foo", value: "bar"),
                               URLQueryItem(name: "fooz", value: "barz")]
        
        let components = URLComponents(url: urlRequest!.url!, resolvingAgainstBaseURL: false)
        
        let sortedQueryItems = components?.queryItems?.sorted { $0.name < $1.name }
        
        XCTAssertTrue(sortedQueryItems == expectedQueries)
    }
    
    func testBuildingURL_WithQueryParamsEncoded_IsSuccessful() {
        let request = MockStandardRequest.validRequestWithQueryParamsEncoded
        
        let urlRequest = request.buildURLRequest()
        
        let expectedQueries = [URLQueryItem(name: "foo", value: "bar%a"),
                               URLQueryItem(name: "fooz", value: "ba#rz")]
        let expectedPercentEndocodedQuery = "foo=bar%25a&fooz=ba%23rz"
        
        let components = URLComponents(url: urlRequest!.url!, resolvingAgainstBaseURL: false)
        
        let sortedQueryItems = components?.queryItems?.sorted { $0.name < $1.name }
        
        XCTAssertTrue(sortedQueryItems == expectedQueries)
        XCTAssertTrue(components?.percentEncodedQuery?.components(separatedBy: "&").sorted() == expectedPercentEndocodedQuery.components(separatedBy: "&").sorted())
    }
    
    func testBuildingURL_WithCustomQueryParamsEncoded_IsSuccessful() {
        let request = MockStandardRequest.validRequestWithCustomQueryParamsEncoded
        
        let urlRequest = request.buildURLRequest()
        
        let expectedQueries = [URLQueryItem(name: "foo", value: "bar%a"),
                               URLQueryItem(name: "fooz", value: "ba#rz"),
                               URLQueryItem(name: "fooz1", value: "ba+rz")]
        let expectedPercentEndocodedQuery = "foo=bar%25a&fooz=ba%23rz&fooz1=ba%2Brz"
        
        let components = URLComponents(url: urlRequest!.url!, resolvingAgainstBaseURL: false)
        
        let sortedQueryItems = components?.queryItems?.sorted { $0.name < $1.name }
        
        XCTAssertTrue(sortedQueryItems == expectedQueries)
        XCTAssertTrue(components?.percentEncodedQuery?.components(separatedBy: "&").sorted() == expectedPercentEndocodedQuery.components(separatedBy: "&").sorted())
    }
    
    func testBuildingURL_WithHeaders_IsSuccessful() {
        let request = MockStandardRequest.validRequestWithHeaders
        
        let urlRequest = request.buildURLRequest()
        
        let expectedHeaders = ["foo": "bar", "fooz": "barz"]
        
        XCTAssertTrue(urlRequest?.allHTTPHeaderFields == expectedHeaders)
    }
    
    func testBuildingURL_WithBody_IsSuccessful() {
        let request = MockStandardRequest.validRequestWithJSONBody
        
        let urlRequest = request.buildURLRequest()
        
        let expectedData =
            """
                {"foo": "bar"}
            """
                .data(using: .utf8)
        
        let expectedHeaders = ["Content-Type": "application/json"]
        
        XCTAssertTrue(urlRequest?.allHTTPHeaderFields == expectedHeaders)
        XCTAssertTrue(urlRequest?.httpBody == expectedData)
    }
    
    func testBuildingNetworkBody_WithDictionary_IsSuccessful() {
        let jsonDecoder = JSONDecoder()
        
        let expectedData =
            """
                {
                    "foo": "bar",
                    "fooz": "barz"
                }
            """
                .data(using: .utf8)!
        
        let expectedFoo = try! jsonDecoder.decode(Foo.self, from: expectedData)
        
        let body = try! NetworkBody(dictionary: ["foo": "bar", "fooz": "barz"],
                                    encoding: .json)
        
        let foo = try! jsonDecoder.decode(Foo.self, from: body.data)
        
        XCTAssertTrue(foo == expectedFoo)
    }
    
//    func testHeaderBuilder() {
//        let request = HeaderBuildTestRequest(bool: true)
//
//        let urlRequest = request.buildURLRequest()
//
//        XCTAssertTrue(urlRequest?.headers.count == 8)
//
//        XCTAssertTrue(urlRequest?.headers["if"] == "test")
//        XCTAssertTrue(urlRequest?.headers["e"] == "f")
//        XCTAssertTrue(urlRequest?.headers["g"] == "h")
//        XCTAssertTrue(urlRequest?.headers["array"] == "test")
//        XCTAssertTrue(urlRequest?.headers["dict"] == "test")
//        XCTAssertTrue(urlRequest?.headers["optional"] == "test")
//        XCTAssertTrue(urlRequest?.headers["foo"] == "bar")
//        XCTAssertTrue(urlRequest?.headers["baz"] == "fooz")
//    }
    
//    func testHeaderBuilder_SecondConditional() {
//        let request = HeaderBuildTestRequest(bool: false)
//        
//        let urlRequest = request.buildURLRequest()
//        
//
//        XCTAssertTrue(urlRequest?.headers["if"] == "test2")
//    }
}
