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
        self.cell = tableView.dequeueReusableCell()
        self.cell?.title.text                 = model.title
        self.cell?.productDescription.text    = model.description
        self.cell?.price.text                 = model.price.toString
        self.cell?.productImageView.image     = nil
        self.cell?.retryButton.isHidden       = true


        let loadImage = { [weak self] in
            guard let self else { return }
            
            self.cell?.productImageContainer.startShimmering()
            self.task = self.imageLoader.loadImageData(from: model.image) {
                [weak self] result in

                let imageData = try? result.get()
                let image = imageData.map(UIImage.init) ?? nil
                self?.cell?.productImageView.setImageAnimated(image)
                self?.cell?.retryButton.isHidden = (image != nil)
        
                self?.cell?.productImageContainer.stopShimmering()
            }
        }
        
        loadImage()
        
        cell?.retryAction = loadImage
        cell?.onReuse = { [weak self] in
            self?.releaseCellForReuse()
        }
        
        return cell!
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
        releaseCellForReuse()
        task?.cancel()
    }
    
    private func releaseCellForReuse() {
        cell = nil
    }
}
