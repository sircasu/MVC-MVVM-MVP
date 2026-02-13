//
//  ProductImageViewModel.swift
//  MVP
//
//  Created by Matteo Casu on 13/02/26.
//

import Foundation

public struct ProductImageViewModel<Image> {
    let title: String
    let description: String
    let price: String
    var image: Image?
    var isLoading: Bool
    var shouldRetry: Bool
}
