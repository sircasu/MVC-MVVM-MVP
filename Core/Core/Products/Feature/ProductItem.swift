//
//  ProductItem.swift
//  Core
//
//  Created by Matteo Casu on 21/12/25.
//

import Foundation

public struct ProductItem: Equatable {
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
}
