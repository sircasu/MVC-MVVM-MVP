//
//  ProductImageLoader.swift
//  MVC
//
//  Created by Matteo Casu on 12/01/26.
//

import Foundation

public protocol ImageLoaderTask {
    func cancel()
}

public protocol ProductImageLoader {
    typealias Result = Swift.Result<Data, Error>
    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> ImageLoaderTask
}
