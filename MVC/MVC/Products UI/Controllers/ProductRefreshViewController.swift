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
    
    var onRefresh: (([ProductItem]) -> Void)?
    
    public init(productsLoader: ProductsLoader) {
        self.productsLoader = productsLoader
    }
    
    @objc func refresh() {
        view.beginRefreshing()
        productsLoader.getProducts { [weak self] result in
            
            switch result {
            case let .success(products):
                self?.onRefresh?(products)
            default: break
            }
            self?.view.endRefreshing()
        }
    }

}
