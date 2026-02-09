//
//  ProductRefreshViewController.swift
//  MVP
//
//  Created by Matteo Casu on 12/01/26.
//

import UIKit

public protocol ProductRefreshViewControllerDelegate {
    func didAskForProductsRefresh()
}

public final class ProductRefreshViewController: NSObject, ProductsLoadingView {

    
    public lazy var view: UIRefreshControl = loadView()
    
    
    private let delegate: ProductRefreshViewControllerDelegate
    
    
    public init(delegate: ProductRefreshViewControllerDelegate) {
        self.delegate = delegate
    }
    
    
    public func loadView() -> UIRefreshControl {

        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        return view
    }
    
    
    func display(_ viewModel: ProductsLoadingViewModel) {
        if viewModel.isLoading {
            view.beginRefreshing()
        } else {
            view.endRefreshing()
        }
    }
    
    @objc func refresh() {
        delegate.didAskForProductsRefresh()
    }
}
