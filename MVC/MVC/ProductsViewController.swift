//
//  ProductsViewController.swift
//  MVC
//
//  Created by Matteo Casu on 22/12/25.
//

import UIKit
import Core

public final class ProductsViewController: UITableViewController {
    
    private var loader: ProductsLoader?
    
    private var onViewIsAppearing: ((ProductsViewController) -> Void)?
    
    
    public convenience init(loader: ProductsLoader) {
        self.init()
        self.loader = loader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        
        onViewIsAppearing = { [weak self] vc in
            vc.onViewIsAppearing = nil
            self?.load()
        }
    }
    
    
    public override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        onViewIsAppearing?(self)
    }
    
    
    @objc private func load() {
        refreshControl?.beginRefreshing()
        loader?.load { [weak self] _ in
            self?.refreshControl?.endRefreshing()
        }
    }
}

