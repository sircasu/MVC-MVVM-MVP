//
//  ProductsViewAdapter.swift
//  MVP
//
//  Created by Matteo Casu on 16/02/26.
//

import UIKit
import Core

public class ProductsViewAdapter: ProductsView {
    
    weak var controller: ProductsViewController?
    let imageLoader: ProductImageLoader
    
    public init(controller: ProductsViewController?, imageLoader: ProductImageLoader) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    

    func display(_ viewModel: ProductsViewModel) {
        

        controller?.tableModel = viewModel.products.map { model in
            let adapter = ProductImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<ProductCellController>, UIImage>(
                model: model,
                imageLoader: imageLoader
            )
            
            let view = ProductCellController(delegate: adapter)
            
            adapter.presenter = ProductImagePresenter(
                productImageView: WeakRefVirtualProxy(view),
                imageTransformer: UIImage.init)
            
            return view

        }

    }
}
