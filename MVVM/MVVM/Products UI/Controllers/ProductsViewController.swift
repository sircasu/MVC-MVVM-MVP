//
//  ProductsViewController.swift
//  MVVM
//
//  Created by Matteo Casu on 22/12/25.
//

import UIKit


extension UITableView {
    func updateHeaderViewFrame() {
        guard let headerView = self.tableHeaderView else { return }
        
        // Update the size of the header based on its internal content.
        headerView.layoutIfNeeded()
        
        // Trigger table view to know that header should be updated.
        let header = self.tableHeaderView
        self.tableHeaderView = header
    }
}

public final class ProductsViewController: UITableViewController, UITableViewDataSourcePrefetching {
    
    public var errorView = ErrorView()
    
    public var refreshController: ProductRefreshViewController?
    
    
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
        
        errorView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableHeaderView = errorView

        tableView.tableHeaderView!.centerXAnchor.constraint(equalTo: tableView.centerXAnchor).isActive = true
        tableView.tableHeaderView!.widthAnchor.constraint(equalTo: tableView.widthAnchor).isActive = true
        tableView.tableHeaderView!.topAnchor.constraint(equalTo: tableView.topAnchor).isActive = true
        tableView.updateHeaderViewFrame()
        
        
        
        tableView.register(ProductCell.self, forCellReuseIdentifier: String(describing: ProductCell.self))

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
        let controller = cellController(forRowAt: indexPath)
        return controller.tableView(tableView, cellForRowAt: indexPath)
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let controller = cellController(forRowAt: indexPath)
        controller.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
    }
    
    public override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let controller = cellController(forRowAt: indexPath)
        controller.tableView?(tableView, willDisplay: cell, forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let controller = cellController(forRowAt: indexPath)
            controller.tableView(tableView, prefetchRowsAt: indexPaths)
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let controller = cellController(forRowAt: indexPath)
            controller.tableView?(tableView, cancelPrefetchingForRowsAt: indexPaths)
        }
    }
    
    
    private func cellController(forRowAt indexPath: IndexPath) -> CellController {
        
        return tableModel[indexPath.row]
    }
    
}

