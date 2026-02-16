//
//  ProductsLoaderPresenterAdapter.swift
//  MVP
//
//  Created by Matteo Casu on 16/02/26.
//

import Foundation
import Core

public class ProductsLoaderPresenterAdapter: ProductRefreshViewControllerDelegate {
    
    let productsLoader: ProductsLoader
    var presenter: ProductsPresenter?
    
    
    public init(productsLoader: ProductsLoader) {
        self.productsLoader = productsLoader
    }
    
    
    public func didAskForProductsRefresh() {
        
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



