//
//  ProductImageDataLoaderPresentationAdapter.swift
//  MVP
//
//  Created by Matteo Casu on 16/02/26.
//

import Foundation
import Core

public final class ProductImageDataLoaderPresentationAdapter<View: ProductImageView, Image>: ProductCellControllerDelegate where View.Image == Image {
    
    let model: ProductItem
    let imageLoader: ProductImageLoader
    private var task: ImageLoaderTask?
    
    var presenter: ProductImagePresenter<View, Image>?
    
    public init(model: ProductItem, imageLoader: ProductImageLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    public func didRequestImage() {

        presenter?.didStartLoadingProduct(for: model)

        task = imageLoader.loadImageData(from: model.image) { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case let .success(imageData):
                presenter?.didFinishLoadingData(with: imageData, for: model)
            case let .failure(error):
                presenter?.didFinishLoadingData(with: error, for: model)
            }
        }
    }

    public func didPreloadImageRequest() {
        didRequestImage()
    }

    public func didCancelImageRequest() {
        task?.cancel()
        task = nil
    }
}
