//
//  WeakRefVirtualProxy.swift
//  MVP
//
//  Created by Matteo Casu on 16/02/26.
//

import UIKit
import Core

final class WeakRefVirtualProxy<T: AnyObject> {
    
    private weak var object: T?
    
    init(_ object: T?) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: ProductsLoadingView where T: ProductsLoadingView {
    func display(_ viewModel: ProductsLoadingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: ProductImageView where T: ProductImageView, T.Image == UIImage {
    func display(_ model: ProductImageViewModel<UIImage>) {
        object?.display(model)
    }
}

