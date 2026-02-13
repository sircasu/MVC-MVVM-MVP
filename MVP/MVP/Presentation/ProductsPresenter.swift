//
//  ProductsPresenter.swift
//  MVP
//
//  Created by Matteo Casu on 09/02/26.
//

import Foundation
import Core


protocol ProductsLoadingView {
    func display(_ viewModel: ProductsLoadingViewModel)
}


protocol ProductsView {
    func display(_ viewModel: ProductsViewModel)
}


final public class ProductsPresenter {
    
    var loadingView: ProductsLoadingView
    var productsView: ProductsView
    
    
    init(loadingView: ProductsLoadingView, productsView: ProductsView) {
        self.loadingView = loadingView
        self.productsView = productsView
    }
    
    
    func didStartLoading() {
        loadingView.display(ProductsLoadingViewModel(isLoading: true))
    }
    
    func didLoadProdcutsWith(products: [ProductItem]) {
        loadingView.display(ProductsLoadingViewModel(isLoading: false))
        productsView.display(ProductsViewModel(products: products))
    }
    
    func didLoadProdcutsWith(error: Error) {
        loadingView.display(ProductsLoadingViewModel(isLoading: false))
    }

}
