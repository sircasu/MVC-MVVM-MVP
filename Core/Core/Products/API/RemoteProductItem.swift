//
//  RemoteProductItem.swift
//  Core
//
//  Created by Matteo Casu on 24/01/26.
//

import Foundation

public struct RemoteProductItem: Decodable {
    public let id: Int
    public let title: String
    public let price: Double
    public let description: String
    public let category: String
    public let image: URL
    
    public init(id: Int, title: String, price: Double, description: String, category: String, image: URL) {
        self.id = id
        self.title = title
        self.price = price
        self.description = description
        self.category = category
        self.image = image
    }
    
    public var toProductItem: ProductItem {
        ProductItem(
            id: id,
            title: title,
            price: price,
            description: description,
            category: category,
            image: image)
    }
}


