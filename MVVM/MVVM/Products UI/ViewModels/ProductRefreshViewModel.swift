//
//  ProductRefreshViewModel.swift
//  MVVM
//
//  Created by Matteo Casu on 05/02/26.
//

import Foundation
import Core

final public class ProductRefreshViewModel {
    
    private let productsLoader: ProductsLoader
    
    var onLoadingStateChange: ((Bool) -> Void)?
    
    
    init(productsLoader: ProductsLoader) {
        self.productsLoader = productsLoader
    }
    
    var onLoadingStart: (() -> Void)?
    var onRefresh: (([ProductItem]) -> Void)?
    var onError: ((Error) -> Void)?
    
    func loadProducts() {
        onLoadingStart?()
        onLoadingStateChange?(true)
        
        productsLoader.getProducts { [weak self] result in

            switch result {
            case let .success(products):
                self?.onRefresh?(products)
            case let .failure(error):
                self?.onError?(error)
            }
            self?.onLoadingStateChange?(false)
        }
    }

}
