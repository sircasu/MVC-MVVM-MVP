//
//  ProductItemMapper.swift
//  Core
//
//  Created by Matteo Casu on 24/01/26.
//

import Foundation

final class ProductItemMapper {
    
    private init() {}
    
    private static var OK_200: Int { 200 }
    
    static func map(data: Data, response: HTTPURLResponse) -> ProductsLoader.Result {
        
        guard response.statusCode == OK_200,
              let items = try? JSONDecoder().decode([RemoteProductItem].self, from: data) else {
            
            return .failure(RemoteProductsLoader.Error.invalidData)
        }
    
        return .success(items.map { $0.toProductItem })
    }
   
}
