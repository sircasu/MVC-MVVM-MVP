//
//  ProductCellController.swift
//  MVVM
//
//  Created by Matteo Casu on 14/01/26.
//

import UIKit
import Core


public typealias CellController = UITableViewDataSource & UITableViewDelegate & UITableViewDataSourcePrefetching



public final class ProductCellController: NSObject {
    var cell: ProductCell?
    private let viewModel: ProductCellControllerViewModel<UIImage>
    
    public init(viewModel: ProductCellControllerViewModel<UIImage>) {
        self.viewModel = viewModel
    }
}


extension ProductCellController: CellController {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = binded(ProductCell())

        viewModel.loadImageData()

        return cell
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        viewModel.preload()
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        viewModel.preload()
    }
    
    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        viewModel.cancelLoad()
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        viewModel.cancelLoad()
    }
    
    private func preload() {
        viewModel.loadImageData()
    }
    
    
    private func binded(_ cell: ProductCell) -> ProductCell {
        cell.title.text                 = viewModel.title
        cell.productDescription.text    = viewModel.description
        cell.price.text                 = viewModel.price
        cell.productImageView.image     = nil
        cell.retryButton.isHidden       = true
        cell.retryAction                = viewModel.loadImageData
        
        viewModel.onImageLoadingStateChange = { [weak cell] isLoading in
            isLoading ? cell?.productImageContainer.startShimmering() : cell?.productImageContainer.stopShimmering()
        }
        
        viewModel.onImageLoad = { [weak cell] image in
            cell?.productImageView.image = image
        }
        
        viewModel.onShouldRetryImageLoadStateChange = { [weak cell] shouldRetry in
            cell?.retryButton.isHidden = !shouldRetry
        }
        
        return cell
    }
}
