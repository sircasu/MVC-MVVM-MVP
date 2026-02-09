//
//  ProductsPresenter.swift
//  MVP
//
//  Created by Matteo Casu on 09/02/26.
//

import Foundation
import Core

struct ProductsLoadingViewModel {
    let isLoading: Bool
}
protocol ProductsLoadingView {
    func display(_ viewModel: ProductsLoadingViewModel)
}

protocol ProductsView {
    func display(_ products: [ProductItem])
}


final public class ProductsPresenter {
    
    private let productsLoader: ProductsLoader
    
    init(productsLoader: ProductsLoader) {
        self.productsLoader = productsLoader
    }
    
    
    var loadingView: ProductsLoadingView?
    var productsView: ProductsView?
    
    
    func loadFeed() {
        
        loadingView?.display(ProductsLoadingViewModel(isLoading: true))
        
        productsLoader.getProducts { [weak self] result in

            switch result {
            case let .success(products):
                self?.productsView?.display(products)
            default: break
            }
            self?.loadingView?.display(ProductsLoadingViewModel(isLoading: false))
        }
    }

}
