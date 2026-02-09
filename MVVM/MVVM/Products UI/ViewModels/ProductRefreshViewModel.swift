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
    
    var onRefresh: (([ProductItem]) -> Void)?
    
    func loadProducts() {
        onLoadingStateChange?(true)
        
        productsLoader.getProducts { [weak self] result in

            switch result {
            case let .success(products):
                self?.onRefresh?(products)
            default: break
            }
            self?.onLoadingStateChange?(false)
        }
    }

}
