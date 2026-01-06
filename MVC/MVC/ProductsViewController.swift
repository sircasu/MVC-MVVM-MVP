//
//  ProductsViewController.swift
//  MVC
//
//  Created by Matteo Casu on 22/12/25.
//

import UIKit
import Core

public protocol ImageLoaderTask {
    func cancel()
}

public protocol ProductImageLoader {
    typealias Result = Swift.Result<Data, Error>
    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> ImageLoaderTask
}

public final class ProductsViewController: UITableViewController, UITableViewDataSourcePrefetching {
    
    private var productsLoaders: ProductsLoader?
    private var imageLoader: ProductImageLoader?
    
    private var tasks = [IndexPath: ImageLoaderTask]()
    
    private var onViewIsAppearing: ((ProductsViewController) -> Void)?
    
    
    public var tableModel: [ProductItem] = [ProductItem]()
    
    
    public convenience init(productsLoader: ProductsLoader, imageLoader: ProductImageLoader) {
        self.init()
        self.productsLoaders = productsLoader
        self.imageLoader = imageLoader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        tableView.prefetchDataSource = self
        
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
        productsLoaders?.load { [weak self] result in
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
        cell.productImageView.image     = nil
        cell.retryButton.isHidden       = true

        let loadImage = { [weak self, weak cell] in
            guard let self else { return }
            
            cell?.productImageContainer.startShimmering()
            self.tasks[indexPath] = self.imageLoader?.loadImageData(from: row.image) {
                [weak cell] result in

                let imageData = try? result.get()
                let image = imageData.map(UIImage.init) ?? nil
                cell?.productImageView.image = image
                cell?.retryButton.isHidden = (image != nil)
        
                cell?.productImageContainer.stopShimmering()
            }
        }
        
        loadImage()
        
        cell.retryAction = loadImage
        
        return cell
    }
    
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tasks[indexPath]?.cancel()
        tasks[indexPath] = nil
    }
    

    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let row = tableModel[indexPath.row]
            _ = imageLoader?.loadImageData(from: row.image) { _ in }
        }
    }
    
}

