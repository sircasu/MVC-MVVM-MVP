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
    private var cell: ProductCell?
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
 

        self.cell = bind(tableView, cellForRowAt: indexPath)

        viewModel.loadImageData()

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
    
    private func preload() {
        viewModel.loadImageData()
    }
    
    private func cancelLoad() {
        releaseCellForReuse()
        viewModel.cancelLoad()
    }
    
    private func releaseCellForReuse() {
        cell = nil
    }
    
    private func bind(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> ProductCell? {

        cell = tableView.dequeueReusableCell()
        cell?.title.text                 = viewModel.title
        cell?.productDescription.text    = viewModel.description
        cell?.price.text                 = viewModel.price
        cell?.productImageView.image     = nil
        cell?.retryButton.isHidden       = true
        cell?.retryAction                = viewModel.loadImageData
        
        viewModel.onImageLoadingStateChange = { [weak self] isLoading in
            isLoading ? self?.cell?.productImageContainer.startShimmering() : self?.cell?.productImageContainer.stopShimmering()
        }
        
        viewModel.onImageLoad = { [weak self] image in
            self?.cell?.productImageView.setImageAnimated(image)
        }
        
        viewModel.onShouldRetryImageLoadStateChange = { [weak self] shouldRetry in
            self?.cell?.retryButton.isHidden = !shouldRetry
        }
        
        return cell
    }
}
