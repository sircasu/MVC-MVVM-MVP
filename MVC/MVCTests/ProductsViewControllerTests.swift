//
//  ProductsViewControllerTests.swift
//  MVCTests
//
//  Created by Matteo Casu on 07/12/25.
//

import XCTest
import Core
import MVC

class ProductsViewControllerTests: XCTestCase {
    
    func test_loadProductsAction_requestProductsFromLoader() {
        
        let (sut, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCallCount, 0, "Expected no loading requests before the view appears")
        
        sut.simulateAppearance()
        XCTAssertEqual(loader.loadCallCount, 1, "Expected a loading request once view is appeared")

        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadCallCount, 2, "Expected another loading request once user initiates reload")
    
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadCallCount, 3, "Expected a third loading request once user initiates reload")
    }
    
    
    func test_loadProductsAction_runsAutomaticallyOnlyOnFirstAppearance() {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadCallCount, 0, "Expected no loading requests before view appears")

        sut.simulateAppearance()
        XCTAssertEqual(loader.loadCallCount, 1, "Expected a loading request once view appears")

        sut.simulateAppearance()
        XCTAssertEqual(loader.loadCallCount , 1, "Expected no loading request the second time view appears")
    }
    
    
    func test_loadingProductsIndicator_isVisibleWhileLoadingProducts() {
        
        let (sut, loader) = makeSUT()
        sut.simulateAppearance()
        
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is appeared")

        
        loader.completesProductsLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading is completed")


        sut.simulateUserInitiatedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates reload")
        
        
        loader.completesProductsLoading(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once reload is completed")
    }
    
    
    func test_loadProductsCompletion_rendersSuccessfullyLoadedProducts() {
        let product0 = makeProduct()
        let product1 = makeProduct(title: "a product 2", price: 12.0, description: "a description 2")
        let product2 = makeProduct(title: "a product 3", price: 4.88, description: "a description 3")
        let (sut, loader) = makeSUT()
        
        
        sut.simulateAppearance()
        assertThat(sut, isRendering: [])

        
        loader.completesProductsLoading(with: [product0], at: 0)
        assertThat(sut, isRendering: [product0])

        
        sut.simulateUserInitiatedReload()
        loader.completesProductsLoading(with: [product0, product1, product2], at: 1)
        assertThat(sut, isRendering: [product0, product1, product2])

    }
    
    
    func test_loadProductCompletion_doesNotAlterCurrentRenderingStateOnError() {
        
        let product0 = makeProduct()
        let product1 = makeProduct(title: "a product 2", price: 12.0, description: "a description 2")
        let (sut, loader) = makeSUT()

        
        sut.simulateAppearance()
        assertThat(sut, isRendering: [])
        
        
        loader.completesProductsLoading(with: [product0, product1], at: 0)
        assertThat(sut, isRendering: [product0, product1])
        
        
        sut.simulateUserInitiatedReload()
        loader.completesProductsLoadingWithError(at: 1)
        assertThat(sut, isRendering: [product0, product1])
    }
    
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ProductsViewController, loader: LoaderSpy) {
        
        let loader = LoaderSpy()
        let sut = ProductsViewController(loader: loader)
        trackForMemoryLeak(sut, file: file, line: line)
        trackForMemoryLeak(loader, file: file, line: line)
        
        return (sut, loader)
    }
    
    private func makeProduct(id: Int = UUID().hashValue, title: String = "a product", price: Double = 3.33, description: String = "a description", category: String = "a category", image: URL = URL(string: "https://any-image-url.com")!) -> ProductItem {
        
        ProductItem(id: id, title: title, price: price, description: description, category: category, image: image)
    }
    
    
    func assertThat(_ sut: ProductsViewController, isRendering items: [ProductItem], file: StaticString = #filePath, line: UInt = #line) {
        
        guard items.count == sut.numberOfRenderedProductViews else {
            XCTFail("Expected \(items.count) got \(sut.numberOfRenderedProductViews) instead", file: file, line: line)
            return
        }
        XCTAssertEqual(sut.numberOfRenderedProductViews, items.count, file: file, line: line)
        
        
        items.enumerated().forEach { (index, item) in
            assertThat(sut, hasViewConfiguredFor: item, at: index, file: file, line: line)
        }
    }
    
    
    func assertThat(_ sut: ProductsViewController, hasViewConfiguredFor product: ProductItem, at index: Int, file: StaticString = #filePath, line: UInt = #line) {
        
        let view = sut.productView(at: index)
        
        guard let cell = view as? ProductCell else {
            XCTFail("Expected \(ProductCell.self) instance but got \(String(describing: view)) indstead", file: file, line: line)
            return
        }
        
        XCTAssertNotNil(cell)
        XCTAssertEqual(cell.titleText, product.title, file: file, line: line)
        XCTAssertEqual(cell.descriptionText, product.description, file: file, line: line)
        XCTAssertEqual(cell.priceText, "\(product.price)", file: file, line: line)
    }
    
    
    class LoaderSpy: ProductsLoader {
        
        typealias Result = Swift.Result<[ProductItem], Error>
        
        private var completions = [(Result) -> Void]()
        var loadCallCount: Int { completions.count }
        
        
        func load(completion: @escaping (Result) -> Void) {
            completions.append(completion)
        }
        
        
        func completesProductsLoading(with products: [ProductItem] = [],  at index: Int = 0) {
            completions[index](Result.success(products))
        }
        
        
        func completesProductsLoadingWithError(at index:Int = 0) {
            let error = NSError(domain: "test", code: 0)
            completions[index](.failure(error))
        }
    }

}


private extension ProductsViewController {
    
    func simulateAppearance() {
        if !isViewLoaded {
            loadViewIfNeeded()
            replaceRefreshControlWithFakeForiOS17Support()
        }
        
        beginAppearanceTransition(true, animated: false) // viewWillAppear
        endAppearanceTransition() // viewIsAppearing+viewDidAppear
    }
    
    
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
    
    var productSection: Int { 0 }
    var numberOfRenderedProductViews: Int {
        tableView.numberOfRows(inSection: productSection)
    }
    
    func productView(at row: Int) -> UITableViewCell? {
        let ds = tableView.dataSource
        let indexPath = IndexPath(row: row, section: productSection)
        return ds?.tableView(tableView, cellForRowAt: indexPath)
    }
    
}


private extension ProductCell {
    var titleText: String? { title.text }
    var descriptionText: String? { productDescription.text }
    var priceText: String? { price.text }
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
