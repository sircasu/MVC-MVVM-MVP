//
//  ProductImageViewModel.swift
//  Core
//
//  Created by Matteo Casu on 05/05/26.
//

import Foundation

public struct ProductImageViewModel<Image> {
    public let title: String
    public let description: String
    public let price: String
    public var image: Image?
    public var isLoading: Bool
    public var shouldRetry: Bool
    
    
    public init(title: String, description: String, price: String, image: Image? = nil, isLoading: Bool, shouldRetry: Bool) {
        self.title = title
        self.description = description
        self.price = price
        self.image = image
        self.isLoading = isLoading
        self.shouldRetry = shouldRetry
    }
}
