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
        
        
        productRefreshViewModel.onRefresh = adaptProductToCellController(forwardingTo: vc, with: MainQueueDispatchDecorator(decoratee: imageLoader))
        
        
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
