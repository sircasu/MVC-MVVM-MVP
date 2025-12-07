//
//  ProductsViewControllerTests.swift
//  MVCTests
//
//  Created by Matteo Casu on 07/12/25.
//

import XCTest
import UIKit

final class ProductsViewController: UIViewController {
    
    private var loader: ProductsViewControllerTests.LoaderSpy?
    
    convenience init(loader: ProductsViewControllerTests.LoaderSpy) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loader?.load()
    }
}


class ProductsViewControllerTests: XCTestCase {
    
    func test_init_doesNotLoadProducts() {
        
        let loader = LoaderSpy()
        let _ = ProductsViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    
    func test_viewDidLoad_loadProducts() {
        
        let loader = LoaderSpy()
        let sut = ProductsViewController(loader: loader)
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCallCount, 1)
    }
    
    
    // MARK: - Helpers
    
    class LoaderSpy {
        
        var loadCallCount: Int = 0
        
        func load() {
            loadCallCount += 1
        }
    }
}
