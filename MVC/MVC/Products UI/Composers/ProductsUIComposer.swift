//
//  ProductsUIComposer.swift
//  MVC
//
//  Created by Matteo Casu on 12/01/26.
//

import UIKit
import Core

public final class ProductsUIComposer {
    
    private init() {}
    
    
    public static func makeProductsUI(productsLoader: ProductsLoader, imageLoader: ProductImageLoader) -> ProductsViewController {
        
        
        let refreshController = ProductRefreshViewController(productsLoader: MainQueueDispatchDecorator(decoratee: productsLoader))

        
        let vc = ProductsViewController(refreshController: refreshController)
        
        
        refreshController.onRefresh = adaptProductToCellController(forwardingTo: vc, with: MainQueueDispatchDecorator(decoratee: imageLoader))
        
        
        return vc
    }
    
    
    private static func adaptProductToCellController(forwardingTo controller: ProductsViewController, with imageLoader: ProductImageLoader) -> ([ProductItem]) -> Void {
        
         { [weak controller] items in
            controller?.tableModel = items.map { ProductCellController(
                model: $0,
                imageLoader: imageLoader
            )}
        }
    }
}

