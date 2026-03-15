//
//  ProductRefreshViewController.swift
//  MVC
//
//  Created by Matteo Casu on 12/01/26.
//

import UIKit
import Core

public final class ProductRefreshViewController: NSObject {
    
    public lazy var view: UIRefreshControl = {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }()
    
    private let productsLoader: ProductsLoader
    
    var onLoadingStart: (() -> Void)?
    var onRefresh: (([ProductItem]) -> Void)?
    var onError: ((Error) -> Void)?
    
    public init(productsLoader: ProductsLoader) {
        self.productsLoader = productsLoader
    }
    
    @objc func refresh() {
        onLoadingStart?()
        view.beginRefreshing()
        productsLoader.getProducts { [weak self] result in
            
            switch result {
            case let .success(products):
                self?.onRefresh?(products)
            case let .failure(error):
                self?.onError?(error)
            }
            self?.view.endRefreshing()
        }
    }

}
