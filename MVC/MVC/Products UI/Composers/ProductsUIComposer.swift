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
        
        let refreshController = ProductRefreshViewController(productsLoader: productsLoader)

        let vc = ProductsViewController(refreshController: refreshController, imageLoader: imageLoader)
        
        return vc
    }
}
