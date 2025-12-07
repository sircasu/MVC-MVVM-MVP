//
//  ProductsViewControllerTests.swift
//  MVCTests
//
//  Created by Matteo Casu on 07/12/25.
//

import XCTest
import UIKit

struct ProductItem {
    let id: Int
    let title: String
    let price: Double
    let description: String
    let category: String
    let image: URL
}

protocol ProductsLoader {
    typealias Result = Swift.Result<[ProductItem], Error>
    func load(completion: @escaping (Result) -> Void)
}


final class ProductsViewController: UIViewController {
    
    private var loader: ProductsLoader?
    
    convenience init(loader: ProductsLoader) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loader?.load() { _ in }
    }
}



class ProductsViewControllerTests: XCTestCase {
    
    func test_init_doesNotLoadProducts() {
        
        let (_, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    
    func test_viewDidLoad_loadProducts() {
        
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCallCount, 1)
    }
    
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ProductsViewController, loader: LoaderSpy) {
        
        let loader = LoaderSpy()
        let sut = ProductsViewController(loader: loader)
        
        return (sut, loader)
    }
    
    class LoaderSpy: ProductsLoader {
        
        typealias Result = Swift.Result<[ProductItem], Error>
        
        
        var loadCallCount: Int = 0
        
        
        func load(completion: @escaping (Result) -> Void) {
            loadCallCount += 1
        }
    }
}
