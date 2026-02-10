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
        

        let productsLoaderPresenterAdapter = ProductsLoaderPresenterAdapter(productsLoader: productsLoader)
                
        let refreshController = ProductRefreshViewController(delegate: productsLoaderPresenterAdapter)
        
        let vc = ProductsViewController(refreshController: refreshController)
        
        let presenter = ProductsPresenter(
            loadingView: WeakRefVirtualProxy(refreshController),
            productsView: ProductsViewAdapter(controller: vc, imageLoader: imageLoader)
        )
                
        productsLoaderPresenterAdapter.presenter = presenter
        
        return vc
    }

}


final class WeakRefVirtualProxy<T: AnyObject> {
    
    private weak var object: T?
    
    init(_ object: T?) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: ProductsLoadingView where T: ProductsLoadingView {
    func display(_ viewModel: ProductsLoadingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: ProductImageView where T: ProductImageView, T.Image == UIImage {
    func display(_ model: ProductImageViewModel<UIImage>) {
        object?.display(model)
    }
}


private class ProductsViewAdapter: ProductsView {
    
    weak var controller: ProductsViewController?
    let imageLoader: ProductImageLoader
    
    init(controller: ProductsViewController?, imageLoader: ProductImageLoader) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    

    func display(_ viewModel: ProductsViewModel) {
        

        controller?.tableModel = viewModel.products.map { model in
            let adapter = ProductImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<ProductCellController>, UIImage>(
                model: model,
                imageLoader: imageLoader
            )
            
            let view = ProductCellController(delegate: adapter)
            
            adapter.presenter = ProductImagePresenter(
                productImageView: WeakRefVirtualProxy(view),
                imageTransformer: UIImage.init)
            
            return view

        }

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



private final class ProductImageDataLoaderPresentationAdapter<View: ProductImageView, Image>: ProductCellControllerDelegate where View.Image == Image {
    
    let model: ProductItem
    let imageLoader: ProductImageLoader
    private var task: ImageLoaderTask?
    
    var presenter: ProductImagePresenter<View, Image>?
    
    init(model: ProductItem, imageLoader: ProductImageLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    func didRequestImage() {

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

    func didPreloadImageRequest() {
        didRequestImage()
    }

    func didCancelImageRequest() {
        task?.cancel()
        task = nil
    }
}
