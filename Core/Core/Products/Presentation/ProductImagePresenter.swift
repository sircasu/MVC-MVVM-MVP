//
//  ProductImagePresenter.swift
//  Core
//
//  Created by Matteo Casu on 05/05/26.
//

import Foundation

public protocol ProductImageView {
    associatedtype Image
    func display(_ model: ProductImageViewModel<Image>)
}


public final class ProductImagePresenter<View: ProductImageView, Image> where View.Image == Image {
    
    private let productImageView: View
    private let imageTransformer: (Data) -> Image?
    
    public init(productImageView: View, imageTransformer: @escaping (Data) -> Image?) {
        self.productImageView = productImageView
        self.imageTransformer = imageTransformer
    }
    
    public func didStartLoading(for model: ProductItem) {
        productImageView.display(
            ProductImageViewModel(
                title: model.title,
                description: model.description,
                price: model.price.toString,
                image: nil,
                isLoading: true,
                shouldRetry: false)
        )
    }
    
    
    private struct InvalidImageDataError: Error {}
    
    
    public func didFinishLoadingData(with data: Data, for model: ProductItem) {
        let image = imageTransformer(data)
        productImageView.display(ProductImageViewModel(
            title: model.title,
            description: model.description,
            price: model.price.toString,
            image: image,
            isLoading: false,
            shouldRetry: image == nil))
    }
    
    
    public func didFinishLoadingData(with error: Error, for model: ProductItem) {
        productImageView.display(ProductImageViewModel(
            title: model.title,
            description: model.description,
            price: model.price.toString,
            image: nil,
            isLoading: false,
            shouldRetry: true))
    }
}
