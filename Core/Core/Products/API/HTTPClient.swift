//
//  HTTPClient.swift
//  Core
//
//  Created by Matteo Casu on 24/01/26.
//

import Foundation

public protocol HTTPClientTask {
    func cancel()
}

public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    
    @discardableResult
    func perform(_ request: URLRequest, completion: @escaping (Result) -> Void) -> HTTPClientTask
}
