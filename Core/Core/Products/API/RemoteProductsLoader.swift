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
                if response.statusCode != 200 {
                    completion(.failure(Error.invalidData))
                } else if response.statusCode == 200, let items = try? JSONDecoder().decode([RemoteProductItem].self, from: data) {
                    completion(.success(items.map { $0.toProductItem }))
                } else {
                    completion(.failure(Error.invalidData))
                }
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
}
