//
//  ProductRefreshViewController.swift
//  MVVM
//
//  Created by Matteo Casu on 12/01/26.
//

import UIKit

public final class ProductRefreshViewController: NSObject {
    
    public lazy var view: UIRefreshControl = binded(UIRefreshControl())
    
    
    private let viewModel: ProductRefreshViewModel
    
    
    public init(viewModel: ProductRefreshViewModel) {
        self.viewModel = viewModel
    }
    
    
    public func binded(_ view: UIRefreshControl) -> UIRefreshControl {
        
        viewModel.onLoadingStateChange = { [weak view] isLoading in
            if isLoading {
                view?.beginRefreshing()
            } else {
                view?.endRefreshing()
            }
        }
        
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        return view
    }

    
    @objc func refresh() {
        viewModel.loadProducts()
    }
}
