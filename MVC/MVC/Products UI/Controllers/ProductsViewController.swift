//
//  ProductsViewController.swift
//  MVC
//
//  Created by Matteo Casu on 22/12/25.
//

import UIKit
import Core

public final class ProductsViewController: UITableViewController, UITableViewDataSourcePrefetching {
    
    public var refreshController: ProductRefreshViewController?
    private var imageLoader: ProductImageLoader?
    
    private var cellControllers = [IndexPath: ProductCellController]()
    
    private var onViewIsAppearing: ((ProductsViewController) -> Void)?
    
    
    public var tableModel = [ProductItem]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    
    public convenience init(refreshController: ProductRefreshViewController, imageLoader: ProductImageLoader) {
        self.init()
        self.refreshController = refreshController
        self.imageLoader = imageLoader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.prefetchDataSource = self
        refreshControl = refreshController?.view
        
        onViewIsAppearing = { [weak self] vc in
            vc.onViewIsAppearing = nil
            
            self?.refreshController?.onRefresh = { [weak self] products in
                self?.tableModel = products
            }
            
            self?.refreshController?.refresh()
        }
    }
    
    
    public override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        onViewIsAppearing?(self)
    }
    
    
    

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableModel.count
    }
    
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cellController(forRowAt: indexPath).view()
    }
    
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        removeCellController(forRowAt: indexPath)
    }
    
    public override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        startTask(forRowAt: indexPath)
    }

    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellController(forRowAt: indexPath).preload()
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(removeCellController)
    }
    
    private func cellController(forRowAt indexPath: IndexPath) -> ProductCellController {
        let cellModel = tableModel[indexPath.row]
        let cellController = ProductCellController(model: cellModel, imageLoader: imageLoader!)
        cellControllers[indexPath] = cellController
        return cellController
    }
    
    private func startTask(forRowAt indexPath: IndexPath) {
//        let row = tableModel[indexPath.row]
//        tasks[indexPath] = imageLoader?.loadImageData(from: row.image) { _ in }
        cellController(forRowAt: indexPath).preload()
    }
    
    private func removeCellController(forRowAt indexPath: IndexPath) {
        cellControllers[indexPath] = nil
    }
}

