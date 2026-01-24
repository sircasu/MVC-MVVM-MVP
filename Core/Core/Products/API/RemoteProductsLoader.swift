//
//  RemoteProductsLoader.swift
//  Core
//
//  Created by Matteo Casu on 24/01/26.
//

import Foundation

public final class RemoteProductsLoader: ProductsLoader {
    
    private let url: URL
    private let client: HTTPClient
    
    
    public enum Error: Swift.Error {
        case invalidData
        case connectivity
    }
    
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func getProducts(completion: @escaping (ProductsLoader.Result) -> Void) {
        
        client.perform(URLRequest(url: url)) { [weak self] result in
            
            guard self != nil else { return }
            
            switch result {
            case let .success((data, response)):
                completion(ProductItemMapper.map(data: data, response: response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
}

