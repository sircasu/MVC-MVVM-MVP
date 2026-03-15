//
//  ProductsUIComposer.swift
//  MVVM
//
//  Created by Matteo Casu on 04/02/26.
//

import UIKit
import Core

public final class ProductsUIComposer {
    
    private init() {}
    
    
    public static func makeProductsUI(productsLoader: ProductsLoader, imageLoader: ProductImageLoader) -> ProductsViewController {
        
        let productRefreshViewModel = ProductRefreshViewModel(productsLoader: MainQueueDispatchDecorator(decoratee: productsLoader))
        let refreshController = ProductRefreshViewController(viewModel: productRefreshViewModel)

        
        let vc = ProductsViewController(refreshController: refreshController)
        vc.title = ProductsViewModel.title
        
        
        productRefreshViewModel.onLoadingStart = { [weak vc] in
            vc?.errorView.message = nil
        }
        
        productRefreshViewModel.onRefresh = adaptProductToCellController(forwardingTo: vc, with: MainQueueDispatchDecorator(decoratee: imageLoader))
        
        productRefreshViewModel.onError = { [weak vc] _ in
            vc?.errorView.message = ProductsViewModel.error
        }
        
        return vc
    }
    
    
    private static func adaptProductToCellController(forwardingTo controller: ProductsViewController, with imageLoader: ProductImageLoader) -> ([ProductItem]) -> Void {
        
        
        { [weak controller] items in
            
            controller?.tableModel = items.map { ProductCellController(
                viewModel: ProductCellControllerViewModel(
                    model: $0,
                    imageLoader: imageLoader,
                    imageTransformer: UIImage.init
                )
            )}
        }
    }
}
