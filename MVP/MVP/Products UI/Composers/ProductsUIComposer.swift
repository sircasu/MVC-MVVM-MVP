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



