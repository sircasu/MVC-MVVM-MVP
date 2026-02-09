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
    
    var loadingView: ProductsLoadingView?
    var productsView: ProductsView?
    
    
    func didStartLoading() {
        loadingView?.display(ProductsLoadingViewModel(isLoading: true))
    }
    
    func didLoadProdcutsWith(products: [ProductItem]) {
        loadingView?.display(ProductsLoadingViewModel(isLoading: false))
        productsView?.display(products)
    }
    
    func didLoadProdcutsWith(error: Error) {
        loadingView?.display(ProductsLoadingViewModel(isLoading: false))
    }

}
