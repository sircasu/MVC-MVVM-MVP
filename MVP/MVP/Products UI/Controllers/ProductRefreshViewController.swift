//
//  ProductRefreshViewController.swift
//  MVP
//
//  Created by Matteo Casu on 12/01/26.
//

import UIKit

public final class ProductRefreshViewController: NSObject, ProductsLoadingView {

    
    public lazy var view: UIRefreshControl = loadView()
    
    
    private let presenter: ProductsPresenter
    
    
    public init(presenter: ProductsPresenter) {
        self.presenter = presenter
    }
    
    
    public func loadView() -> UIRefreshControl {

        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        return view
    }
    
    
    func display(isLoading: Bool) {
        if isLoading {
            view.beginRefreshing()
        } else {
            view.endRefreshing()
        }
    }
    
    @objc func refresh() {
        presenter.loadFeed()
    }
}
