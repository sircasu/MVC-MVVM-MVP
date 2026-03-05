//
//  ProductsPresenter.swift
//  MVP
//
//  Created by Matteo Casu on 09/02/26.
//

import Foundation
import Core


struct ProductsErrorViewModel {
    let message: String?
}

protocol ProductsErrorView {
    func display(_ viewModel: ProductsErrorViewModel)
}


protocol ProductsLoadingView {
    func display(_ viewModel: ProductsLoadingViewModel)
}


protocol ProductsView {
    func display(_ viewModel: ProductsViewModel)
}


final public class ProductsPresenter {
    
    var loadingView: ProductsLoadingView
    var productsView: ProductsView
    var errorView: ProductsErrorView
    
    static var title: String {
        return NSLocalizedString("PRODUCTS_VIEW_TITLE", tableName: "Products", bundle: Bundle(for: ProductsPresenter.self), comment: "Title for the product view")
    }
    
    init(loadingView: ProductsLoadingView, productsView: ProductsView, errorView: ProductsErrorView) {
        self.loadingView = loadingView
        self.productsView = productsView
        self.errorView = errorView
    }
    
    
    func didStartLoading() {
        loadingView.display(ProductsLoadingViewModel(isLoading: true))
        errorView.display(ProductsErrorViewModel(message: nil))
    }
    
    func didLoadProdcutsWith(products: [ProductItem]) {
        loadingView.display(ProductsLoadingViewModel(isLoading: false))
        productsView.display(ProductsViewModel(products: products))
    }
    
    func didLoadProdcutsWith(error: Error) {
        loadingView.display(ProductsLoadingViewModel(isLoading: false))
        errorView.display(ProductsErrorViewModel(message: "error"))
    }

}
