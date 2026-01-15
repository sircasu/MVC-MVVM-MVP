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
    
    
    private var onViewIsAppearing: ((ProductsViewController) -> Void)?
    
    
    public var tableModel = [CellController]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    
    convenience init(refreshController: ProductRefreshViewController) {
        self.init()
        self.refreshController = refreshController
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.prefetchDataSource = self
        refreshControl = refreshController?.view
        
        onViewIsAppearing = { [weak self] vc in
            vc.onViewIsAppearing = nil
            
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
        cancelCellControllerLoad(forRowAt: indexPath)
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
        indexPaths.forEach(cancelCellControllerLoad)
    }
    
    private func cellController(forRowAt indexPath: IndexPath) -> CellController {

        return tableModel[indexPath.row]
    }
    
    private func startTask(forRowAt indexPath: IndexPath) {

        cellController(forRowAt: indexPath).preload()
    }
    
    private func cancelCellControllerLoad(forRowAt indexPath: IndexPath) {
        cellController(forRowAt: indexPath).cancelLoad()
    }
}

