//
//  MainQueueDispatchDecorator.swift
//  MVC
//
//  Created by Matteo Casu on 16/02/26.
//

import Foundation
import Core

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
