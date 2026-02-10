//
//  ProductImagePresenter.swift
//  MVP
//
//  Created by Matteo Casu on 10/02/26.
//

import Foundation
import Core

public struct ProductImageViewModel<Image> {
    let title: String
    let description: String
    let price: String
    var image: Image?
    var isLoading: Bool
    var shouldRetry: Bool
}

public protocol ProductImageView {
    associatedtype Image
    func display(_ model: ProductImageViewModel<Image>)
}


public class ProductImagePresenter<View: ProductImageView, Image> where View.Image == Image {

    private let productImageView: View
    private let imageTransformer: (Data) -> Image?
    
    public init(productImageView: View, imageTransformer: @escaping (Data) -> Image?) {
        self.productImageView = productImageView
        self.imageTransformer = imageTransformer
    }
    
    
    func didStartLoadingProduct(for model: ProductItem) {
        productImageView.display(ProductImageViewModel(
            title: model.title,
            description: model.description,
            price: model.price.toString,
            image: nil,
            isLoading: true,
            shouldRetry: false))
    }

    
    private struct InvalidImageDataError: Error {}
    
    
    func didFinishLoadingData(with data: Data, for model: ProductItem) {
        guard let image = imageTransformer(data) else {
            return didFinishLoadingData(with: InvalidImageDataError(), for: model)
        }
        
        productImageView.display(ProductImageViewModel(
            title: model.title,
            description: model.description,
            price: model.price.toString,
            image: image,
            isLoading: false,
            shouldRetry: false))
    }
    
    
    func didFinishLoadingData(with error: Error, for model: ProductItem) {
        productImageView.display(ProductImageViewModel(
            title: model.title,
            description: model.description,
            price: model.price.toString,
            image: nil,
            isLoading: false,
            shouldRetry: true))
    }
}
