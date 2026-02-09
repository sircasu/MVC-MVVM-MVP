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
    
    weak var object: T?
    
    init(_ object: T?) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: ProductsLoadingView where T: ProductsLoadingView {
    func display(_ viewModel: ProductsLoadingViewModel) {
        object?.display(viewModel)
    }
}


private class ProductsViewAdapter: ProductsView {
    
    weak var controller: ProductsViewController?
    let imageLoader: ProductImageLoader
    
    init(controller: ProductsViewController?, imageLoader: ProductImageLoader) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    func display(_ products: [ProductItem]) {
        controller?.tableModel = products.map { ProductCellController(
            viewModel: ProductCellControllerViewModel(
                model: $0,
                imageLoader: imageLoader,
                imageTransformer: UIImage.init
            )
        )}
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
