//
//  SharedTestHelpers.swift
//  CoreTests
//
//  Created by Matteo Casu on 31/01/26.
//

import Foundation


func anyURL() -> URL {
    URL(string: "https://any-url.com")!
}

func anyNSError() -> NSError {
    NSError(domain: "test", code: 0)
}

func anyRequest() -> URLRequest {
    URLRequest(url: anyURL())
}

func anyURLResponse() -> URLResponse {
    URLResponse()
}

func anyHTTPURLResponse() -> HTTPURLResponse {
    HTTPURLResponse()
}

func emptyData() -> Data {
    Data()
}

func anyData() -> Data {
    Data("any data".utf8)
}

