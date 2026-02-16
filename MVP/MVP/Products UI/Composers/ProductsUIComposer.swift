//
//  ProductsUIComposer.swift
//  MVP
//
//  Created by Matteo Casu on 04/02/26.
//

import UIKit
import Core

public final class ProductsUIComposer {
    
    private init() {}
    
    
    public static func makeProductsUI(productsLoader: ProductsLoader, imageLoader: ProductImageLoader) -> ProductsViewController {
        
        
        let productsLoaderPresenterAdapter = ProductsLoaderPresenterAdapter(productsLoader: MainQueueDispatchDecorator(decoratee: productsLoader))
                
        let refreshController = ProductRefreshViewController(delegate: productsLoaderPresenterAdapter)
        
        let vc = ProductsViewController(refreshController: refreshController)
        
        let presenter = ProductsPresenter(
            loadingView: WeakRefVirtualProxy(refreshController),
            productsView: ProductsViewAdapter(
                controller: vc,
                imageLoader: MainQueueDispatchDecorator(decoratee: imageLoader)
            )
        )
                
        productsLoaderPresenterAdapter.presenter = presenter
        
        return vc
    }

}






private class ProductsLoaderPresenterAdapter: ProductRefreshViewControllerDelegate {
    
    let productsLoader: ProductsLoader
    var presenter: ProductsPresenter?
    
    
    init(productsLoader: ProductsLoader) {
        self.productsLoader = productsLoader
    }
    
    
    func didAskForProductsRefresh() {
        
        presenter?.didStartLoading()
        
        productsLoader.getProducts { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case let .success(products):
                presenter?.didLoadProdcutsWith(products: products)
            case let .failure(error):
                presenter?.didLoadProdcutsWith(error: error)
            }
        }
    }
}



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
