//
//  RemoteProductImageDataLoader.swift
//  Core
//
//  Created by Matteo Casu on 02/02/26.
//

import Foundation

final public class RemoteProductImageDataLoader: ProductImageLoader {
    
    private let client: HTTPClient
    
    public init(client: HTTPClient) {
        self.client = client
    }
    
    
    public enum Error: Swift.Error {
        case invalidData
        case connectivity
    }
    
    
    private final class HTTPClientTaskWrapper: ImageLoaderTask {
        
        private var completion: ((ProductImageLoader.Result) -> Void)?
        var wrapped: HTTPClientTask?
        
        init(_ completion: @escaping (ProductImageLoader.Result) -> Void) {
            self.completion = completion
        }
        
        func complete(with result: ProductImageLoader.Result) {
            completion?(result)
        }
        
        func cancel() {
            preventFurtherCompletion()
            wrapped?.cancel()
        }
        
        private func preventFurtherCompletion() {
            completion = nil
        }
    }
    
    
    public func loadImageData(from url: URL, completion: @escaping (ProductImageLoader.Result) -> Void) -> ImageLoaderTask {
       
        let urlRequest = URLRequest(url: url)
        
        let task = HTTPClientTaskWrapper(completion)
        task.wrapped = client.perform(urlRequest) { [weak self] result in
            
            guard self != nil else { return }
        
            switch result {
            case let .success((data, response)):
                if response.statusCode == 200, !data.isEmpty {

                    task.complete(with: .success(data))
                } else {
                    task.complete(with: .failure(RemoteProductImageDataLoader.Error.invalidData))
                }
                
            case .failure:
                task.complete(with: .failure(RemoteProductImageDataLoader.Error.connectivity))
            }

        }
        
        return task
    }
}
