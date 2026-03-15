//
//  ProductsPresenterTests.swift
//  CoreTests
//
//  Created by Matteo Casu on 15/03/26.
//

import XCTest
import Core

/// Just for exercise add tests
final class ProductsPresenterTests: XCTestCase {
    
    func test_title_isLocalized() {
        XCTAssertEqual(ProductsPresenter.title, localized("PRODUCTS_VIEW_TITLE"))
    }
    
    
    func test_init_doesNotSendMessagesToView() {
  
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty)
    }
    
    
    func test_didStartLoading_displaysNoErrorMessageAndIsLoadingMessage() {
        
        let (sut, view) = makeSUT()
        
        sut.didStartLoading()
        
        XCTAssertEqual(view.messages, [
            .display(errorMessage: .none),
            .display(isLoading: true)
        ])
    }
    
    
    func test_didLoadProductWithProducts_displayIsLoadingFalseMessageAndProducts() {
        
        let (sut, view) = makeSUT()
        
        let products = [makeItem().model]
        sut.didLoadProductsWith(products: products)
        
        XCTAssertEqual(view.messages, [
            .display(isLoading: false),
            .display(products: products)
        ])
    }
    
    
    func test_didLoadProductsWithError_displayIsLoadingFalseAndErrorMessage() {
        
        let (sut, view) = makeSUT()
        
        sut.didLoadProductsWith(error: anyNSError())
        
        XCTAssertEqual(view.messages, [
            .display(isLoading: false),
            .display(errorMessage: localized("PRODUCTS_VIEW_CONNECTION_ERROR"))
        ])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ProductsPresenter, view: ViewSpy) {
        
        let view = ViewSpy()
        let sut = ProductsPresenter(loadingView: view, productsView: view, errorView: view)
        trackForMemoryLeak(sut, file: file, line: line)
        trackForMemoryLeak(view, file: file, line: line)
        
        return (sut, view)
    }
    
    
    func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let table = "Products"
        let bundle = Bundle(for: ProductsPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if key == value {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
    }
    
    
    private class ViewSpy: ProductsErrorView, ProductsLoadingView, ProductsView {
                
        enum Message: Equatable {
            case display(errorMessage: String?)
            case display(isLoading: Bool)
            case display(products: [ProductItem])
        }
        
        private(set) var messages = [Message]()
        
        
        func display(_ viewModel: ProductsErrorViewModel) {
            messages.append(.display(errorMessage: viewModel.message))
        }
        
        func display(_ viewModel: ProductsLoadingViewModel) {
            messages.append(.display(isLoading: viewModel.isLoading))
        }
        
        func display(_ viewModel: ProductsViewModel) {
            messages.append(.display(products: viewModel.products))
        }
    }
    
}
