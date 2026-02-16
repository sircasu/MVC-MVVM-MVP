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


final class MainQueueDispatchDecorator<T> {

    let decoratee: T

    init(decoratee: T) {
        self.decoratee = decoratee
    }

    func dispatch(completion: @escaping () -> Void) {
        guard Thread.isMainThread else {
            return DispatchQueue.main.async(execute: completion)
        }

        completion()
    }
}


extension MainQueueDispatchDecorator: ProductsLoader where T == ProductsLoader {

    func getProducts(completion: @escaping (ProductsLoader.Result) -> Void) {

        decoratee.getProducts { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }

}

extension MainQueueDispatchDecorator: ProductImageLoader where T == ProductImageLoader {

    func loadImageData(from url: URL, completion: @escaping (ProductImageLoader.Result) -> Void) -> any ImageLoaderTask {

        decoratee.loadImageData(from: url) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}
