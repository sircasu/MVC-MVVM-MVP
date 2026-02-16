//
//  ProductsUIComposer.swift
//  MVP
//
//  Created by Matteo Casu on 04/02/26.
//

import UIKit
import Core

public final class ProductsUIComposer {
    
    private init() {}
    
    
    public static func makeProductsUI(productsLoader: ProductsLoader, imageLoader: ProductImageLoader) -> ProductsViewController {
        
        
        let productsLoaderPresenterAdapter = ProductsLoaderPresenterAdapter(productsLoader: MainQueueDispatchDecorator(decoratee: productsLoader))
                
        let refreshController = ProductRefreshViewController(delegate: productsLoaderPresenterAdapter)
        
        let vc = ProductsViewController(refreshController: refreshController)
        
        let presenter = ProductsPresenter(
            loadingView: WeakRefVirtualProxy(refreshController),
            productsView: ProductsViewAdapter(
                controller: vc,
                imageLoader: MainQueueDispatchDecorator(decoratee: imageLoader)
            )
        )
                
        productsLoaderPresenterAdapter.presenter = presenter
        
        return vc
    }

}
