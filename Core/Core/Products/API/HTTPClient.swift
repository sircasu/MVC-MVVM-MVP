//
//  HTTPClient.swift
//  Core
//
//  Created by Matteo Casu on 24/01/26.
//

import Foundation

public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    func perform(_ request: URLRequest, completion: @escaping (Result) -> Void)
}
