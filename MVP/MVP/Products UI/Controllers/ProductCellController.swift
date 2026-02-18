//
//  ProductCellController.swift
//  MVP
//
//  Created by Matteo Casu on 14/01/26.
//

import UIKit
import Core


public typealias CellController = UITableViewDataSource & UITableViewDelegate & UITableViewDataSourcePrefetching


public protocol ProductCellControllerDelegate {
    func didRequestImage()
    func didPreloadImageRequest()
    func didCancelImageRequest()
    
}

public final class ProductCellController: NSObject {
    private var cell: ProductCell?
    private let delegate: ProductCellControllerDelegate
    
    public init(delegate: ProductCellControllerDelegate) {
        self.delegate = delegate
    }
}


extension ProductCellController: CellController, ProductImageView {

    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        self.cell = tableView.dequeueReusableCell()
        delegate.didRequestImage()
        return self.cell!
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

    
    public func display(_ viewModel: ProductImageViewModel<UIImage>) {
        cell?.title.text                 = viewModel.title
        cell?.productDescription.text    = viewModel.description
        cell?.price.text                 = viewModel.price
        cell?.retryButton.isHidden       = !viewModel.shouldRetry
        cell?.retryAction                = delegate.didRequestImage
        cell?.productImageView.image     = viewModel.image
        cell?.productImageView.setImageAnimated(viewModel.image)
        
        cell?.onReuse = { [weak self] in
            self?.releaseCellForReuse()
        }

        viewModel.isLoading ?
            cell?.productImageContainer.startShimmering()
            :
            cell?.productImageContainer.stopShimmering()
    }
    
    
    private func preload() {
        delegate.didPreloadImageRequest()
    }
    
    private func cancelLoad() {
        releaseCellForReuse()
        delegate.didCancelImageRequest()
    }
    
    private func releaseCellForReuse() {
        cell = nil
    }
}
