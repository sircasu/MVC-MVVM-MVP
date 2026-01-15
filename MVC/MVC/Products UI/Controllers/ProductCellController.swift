//
//  ProductCellController.swift
//  MVC
//
//  Created by Matteo Casu on 14/01/26.
//

import UIKit
import Core

public protocol CellController {
    func view() -> UITableViewCell
    func preload()
    func cancelLoad()
}

public final class ProductCellController: CellController {
    
    private var task: ImageLoaderTask?
    private let model: ProductItem
    private let imageLoader: ProductImageLoader
    
    public init(model: ProductItem, imageLoader: ProductImageLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    public func view() -> UITableViewCell {
        
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
        
        return cell
    }
    
    
    public func preload() {
        task = imageLoader.loadImageData(from: model.image) { _ in }
    }
    
    
    public func cancelLoad() {
        task?.cancel()
    }
    

}


