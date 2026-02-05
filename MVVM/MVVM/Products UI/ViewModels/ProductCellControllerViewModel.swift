//
//  ProductCellControllerViewModel.swift
//  MVVM
//
//  Created by Matteo Casu on 05/02/26.
//

import Foundation
import Core

public class ProductCellControllerViewModel<Image> {
    typealias Observer<T> = (T) -> Void
    
    private var task: ImageLoaderTask?
    private let model: ProductItem
    private let imageLoader: ProductImageLoader
    private let imageTransformer: (Data) -> Image?
    
    public init(model: ProductItem, imageLoader: ProductImageLoader, imageTransformer: @escaping (Data) -> Image?) {
        self.model = model
        self.imageLoader = imageLoader
        self.imageTransformer = imageTransformer
    }
    
    
    var title: String { model.title }
    var description: String { model.description }
    var price: String { model.price.toString }
    
    var onImageLoad: Observer<Image>?
    var onImageLoadingStateChange: Observer<Bool>?
    var onShouldRetryImageLoadStateChange: Observer<Bool>?

    
    func loadImageData() {
        onImageLoadingStateChange?(true)
        onShouldRetryImageLoadStateChange?(false)

        
        task = imageLoader.loadImageData(from: model.image) { [weak self] result in
  
            guard let self else { return }
            
            if let imageData = (try? result.get()).flatMap(imageTransformer) {
                onImageLoad?(imageData)
            } else {
                onShouldRetryImageLoadStateChange?(true)
            }
    
            onImageLoadingStateChange?(false)
        }
    }
    
    func preload() {
        loadImageData()
    }
    
    func cancelLoad() {
        task?.cancel()
        task = nil
    }
}
