//
//  ProductsViewControllerTests+LoaderSpy.swift
//  MVCTests
//
//  Created by Matteo Casu on 09/01/26.
//

import Foundation
import Core
import MVVM

class LoaderSpy: ProductsLoader, ProductImageLoader {
    
    
    // MARK: - ProductsLoader
    
    typealias Result = Swift.Result<[ProductItem], Error>
    
    private var productRequests = [(Result) -> Void]()
    var loadProductCallCount: Int { productRequests.count }
    
    
    func getProducts(completion: @escaping (Result) -> Void) {
        productRequests.append(completion)
    }
    
    
    func completesProductsLoading(with products: [ProductItem] = [],  at index: Int = 0) {
        productRequests[index](Result.success(products))
    }
    
    
    func completesProductsLoadingWithError(at index:Int = 0) {
        let error = NSError(domain: "test", code: 0)
        productRequests[index](.failure(error))
    }
    
    
    // MARK: - ProductImageLoader
    
    typealias ImageLoaderResult = Swift.Result<Data, Error>

    private struct TaskSpy: ImageLoaderTask {
        var cancelCallback: () -> Void
        func cancel() {
            cancelCallback()
        }
    }
    
    var loadedImageURLs: [URL] {
        imageRequests.map { $0.url }
    }
    private(set) var cancelledImageURLs = [URL]()
    private var imageRequests = [(url: URL, completion:(ImageLoaderResult) -> Void)]()
    
    func loadImageData(from url: URL, completion: @escaping (ImageLoaderResult) -> Void) -> ImageLoaderTask {

        imageRequests.append((url, completion))
        
        return TaskSpy { [weak self] in
            self?.cancelledImageURLs.append(url)
        }
    }

    
    func completeImageLoading(with imageData: Data = Data(), at index: Int = 0) {
        imageRequests[index].completion(.success(imageData))
    }
    
    
    func completeImageLoadingWithError(at index: Int = 0) {
        let error = NSError(domain: "test", code: 0)
        imageRequests[index].completion(.failure(error))
    }
}
