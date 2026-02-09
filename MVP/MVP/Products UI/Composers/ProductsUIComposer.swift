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
        
        let presenter = ProductsPresenter(productsLoader: productsLoader)
        let refreshController = ProductRefreshViewController(presenter: presenter)
        
        let vc = ProductsViewController(refreshController: refreshController)
        
        presenter.loadingView = WeakRefVirtualProxy(refreshController)
        presenter.productsView = ProductsViewAdapter(controller: vc, imageLoader: imageLoader)
                
        return vc
    }

}


final class WeakRefVirtualProxy<T: AnyObject> {
    
    weak var object: T?
    
    init(_ object: T?) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: ProductsLoadingView where T: ProductsLoadingView {
    func display(_ viewModel: ProductsLoadingViewModel) {
        object?.display(viewModel)
    }
}


private class ProductsViewAdapter: ProductsView {
    
    weak var controller: ProductsViewController?
    let imageLoader: ProductImageLoader
    
    init(controller: ProductsViewController?, imageLoader: ProductImageLoader) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    func display(_ products: [ProductItem]) {
        controller?.tableModel = products.map { ProductCellController(
            viewModel: ProductCellControllerViewModel(
                model: $0,
                imageLoader: imageLoader,
                imageTransformer: UIImage.init
            )
        )}
    }
}
