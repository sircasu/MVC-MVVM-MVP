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


final class ProductsViewController: UITableViewController {
    
    private var loader: ProductsLoader?
    
    convenience init(loader: ProductsLoader) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
    }
    
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        load()
    }
    
    
    @objc private func load() {
        refreshControl?.beginRefreshing()
        loader?.load { [weak self] _ in
            self?.refreshControl?.endRefreshing()
        }
    }
}



class ProductsViewControllerTests: XCTestCase {
    
    func test_loadProductAction_requestProductsFromLoader() {
        
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded() // viewDidLoad
        
        XCTAssertEqual(loader.loadCallCount, 0, "Expected no loading requests before the view appears")

        sut.beginAppearanceTransition(true, animated: false) // viewWillAppear
        sut.endAppearanceTransition() // viewIsAppearing+viewDidAppear

        
        XCTAssertEqual(loader.loadCallCount, 1, "Expected a loading request once view is appeared")

        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadCallCount, 2, "Expected another loading request once user initiates reload")
    
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadCallCount, 3, "Expected a third loading request once user initiates reload")
    }
    
    
    func test_loadingProductsIndicator_isVisibleWhileLoadingProducts() {
        
        let (sut, loader) = makeSUT()
        sut.replaceRefreshControlWithFakeForiOS17Support()
        
        sut.loadViewIfNeeded()
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator until view is appeared")
        
        
        sut.beginAppearanceTransition(true, animated: false)
        sut.endAppearanceTransition()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is appeared")

        
        loader.completesProductsLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading is completed")


        sut.simulateUserInitiatedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates reload")
        
        
        loader.completesProductsLoading(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once reload is completed")
    }
    
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ProductsViewController, loader: LoaderSpy) {
        
        let loader = LoaderSpy()
        let sut = ProductsViewController(loader: loader)
        trackForMemoryLeak(sut, file: file, line: line)
        trackForMemoryLeak(loader, file: file, line: line)
        
        return (sut, loader)
    }
    
    class LoaderSpy: ProductsLoader {
        
        typealias Result = Swift.Result<[ProductItem], Error>
        
        private var completions = [(Result) -> Void]()
        var loadCallCount: Int { completions.count }
        
        
        func load(completion: @escaping (Result) -> Void) {
            completions.append(completion)
        }
        
        
        func completesProductsLoading(at index: Int = 0) {
            completions[index](Result.success([]))
        }
    }

}


private extension ProductsViewController {
    
    func replaceRefreshControlWithFakeForiOS17Support() {
        let fake = FakeRefreshControl()
        
        refreshControl?.allTargets.forEach { target in
            refreshControl?.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach { action in
                fake.addTarget(target, action: Selector(action), for: .valueChanged)
            }
        }
        
        refreshControl = fake
    }
    
    
    func simulateUserInitiatedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    
    var isShowingLoadingIndicator: Bool { refreshControl?.isRefreshing == true }
}


private extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}


private class FakeRefreshControl: UIRefreshControl {
    
    private var _isRefreshing = false
    
    
    override var isRefreshing: Bool { _isRefreshing }
    
    
    override func beginRefreshing() {
        _isRefreshing = true
    }
    
    override func endRefreshing() {
        _isRefreshing = false
    }
}



extension XCTestCase {
    
    func trackForMemoryLeak(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated, Potential memory leak.", file: file, line: line)
        }
    }
}
