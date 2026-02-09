//
//  ProductsPresenter.swift
//  MVP
//
//  Created by Matteo Casu on 09/02/26.
//

import Foundation
import Core


protocol ProductsLoadingView {
    func display(isLoading: Bool)
}

protocol ProductsView {
    func display(products: [ProductItem])
}


final public class ProductsPresenter {
    
    private let productsLoader: ProductsLoader
    
    init(productsLoader: ProductsLoader) {
        self.productsLoader = productsLoader
    }
    
    
    var loadingView: ProductsLoadingView?
    var productsView: ProductsView?
    
    
    func loadFeed() {
        
        loadingView?.display(isLoading: true)
        
        productsLoader.getProducts { [weak self] result in

            switch result {
            case let .success(products):
                self?.productsView?.display(products: products)
            default: break
            }
            self?.loadingView?.display(isLoading: false)
        }
    }

}
