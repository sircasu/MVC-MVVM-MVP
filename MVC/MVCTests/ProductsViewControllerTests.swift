//
//  ProductsViewControllerTests.swift
//  MVCTests
//
//  Created by Matteo Casu on 07/12/25.
//

import XCTest


class ProductsViewController {
    init(loader: ProductsViewControllerTests.LoaderSpy) {}
}


class ProductsViewControllerTests: XCTestCase {
    
    func test_init_doesNotLoadProducts() {
        
        let loader = LoaderSpy()
        let _ = ProductsViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    // MARK: - Helpers
    
    class LoaderSpy {
        
        var loadCallCount: Int = 0
        
        func load() {
            loadCallCount += 1
        }
    }
}
