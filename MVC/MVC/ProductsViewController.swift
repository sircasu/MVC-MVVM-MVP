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
    
    
    public var tableModel: [ProductItem] = [ProductItem]()
    
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
        loader?.load { [weak self] result in
            switch result {
            case let .success(products):
                self?.tableModel = products
                self?.tableView.reloadData()
            default: break
            }
            self?.refreshControl?.endRefreshing()
        }
    }
    
    

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableModel.count
    }
    
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = tableModel[indexPath.row]
        let cell = ProductCell()
        cell.title.text                 = row.title
        cell.productDescription.text    = row.description
        cell.price.text                 = row.price.toString
        return cell
    }
}

