//
//  ProductsPresenter.swift
//  Core
//
//  Created by Matteo Casu on 15/03/26.
//

import Foundation

public protocol ProductsView {
    func display(_ viewModel: ProductsViewModel)
}

public protocol ProductsLoadingView {
    func display(_ viewModel: ProductsLoadingViewModel)
}

public protocol ProductsErrorView {
    func display(_ viewModel: ProductsErrorViewModel)
}


public class ProductsPresenter {
    
    private var loadingView: ProductsLoadingView
    private var productsView: ProductsView
    private let errorView: ProductsErrorView
    
    
    public static var title: String {
        return NSLocalizedString("PRODUCTS_VIEW_TITLE", tableName: "Products", bundle: Bundle(for: ProductsPresenter.self), comment: "Title for the product view")
    }
    
    private var productsLoadError: String {
        return NSLocalizedString("PRODUCTS_VIEW_CONNECTION_ERROR",
             tableName: "Products",
             bundle: Bundle(for: ProductsPresenter.self),
             comment: "Error message displayed when we can't load products from the server")
    }
    
    public init(loadingView: ProductsLoadingView, productsView: ProductsView, errorView: ProductsErrorView) {
        self.loadingView    = loadingView
        self.productsView   = productsView
        self.errorView      = errorView
    }
    
    
    public func didStartLoading() {
        errorView.display(.noError)
        loadingView.display(ProductsLoadingViewModel(isLoading: true))
    }
    
    public func didLoadProductsWith(products: [ProductItem]) {
        loadingView.display(ProductsLoadingViewModel(isLoading: false))
        productsView.display(ProductsViewModel(products: products))
    }
    
    public func didLoadProductsWith(error: Error) {
        loadingView.display(ProductsLoadingViewModel(isLoading: false))
        errorView.display(.error(message: productsLoadError))
    }
}
