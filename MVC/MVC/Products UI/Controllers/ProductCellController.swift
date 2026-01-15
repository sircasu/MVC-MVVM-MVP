//
//  ProductCellController.swift
//  MVC
//
//  Created by Matteo Casu on 14/01/26.
//

import UIKit
import Core


public typealias CellController = UITableViewDataSource & UITableViewDelegate & UITableViewDataSourcePrefetching


public final class ProductCellController: NSObject {
    
    private var task: ImageLoaderTask?
    private let model: ProductItem
    private let imageLoader: ProductImageLoader
    private var cell: ProductCell?
    
    public init(model: ProductItem, imageLoader: ProductImageLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
}

extension ProductCellController: CellController {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ProductCell()
        cell.title.text                 = model.title
        cell.productDescription.text    = model.description
        cell.price.text                 = model.price.toString
        cell.productImageView.image     = nil
        cell.retryButton.isHidden       = true

        let loadImage = { [weak self, weak cell] in
            guard let self else { return }
            
            cell?.productImageContainer.startShimmering()
            self.task = self.imageLoader.loadImageData(from: model.image) {
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
        
        self.cell = cell
        return cell
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        preload()
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        preload()
    }
    
    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelLoad()
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        cancelLoad()
    }
    
    private func preload() {
        task = imageLoader.loadImageData(from: model.image) { _ in }
    }
    
    private func cancelLoad() {
        task?.cancel()
        cell = nil
    }
    
}
