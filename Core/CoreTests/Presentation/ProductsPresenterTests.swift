//
//  ProductsPresenterTests.swift
//  CoreTests
//
//  Created by Matteo Casu on 15/03/26.
//

import XCTest
import Core

struct ProductsErrorViewModel {
    let message: String?
    
    static var noError: ProductsErrorViewModel {
        ProductsErrorViewModel(message: nil)
    }
}

protocol ProductsErrorView {
    func display(_ viewModel: ProductsErrorViewModel)
}


protocol ProductsLoadingView {
    func display(_ viewModel: ProductsLoadingViewModel)
}

struct ProductsLoadingViewModel {
    let isLoading: Bool
}

protocol ProductsView {
    func display(_ viewModel: ProductsViewModel)
}

struct ProductsViewModel {
    let products: [ProductItem]
}


class ProductsPresenter {
    
    private var loadingView: ProductsLoadingView
    private var productsView: ProductsView
    private let errorView: ProductsErrorView
    
    init(loadingView: ProductsLoadingView, productsView: ProductsView, errorView: ProductsErrorView) {
        self.loadingView    = loadingView
        self.productsView   = productsView
        self.errorView      = errorView
    }
    
    
    func didStartLoading() {
        errorView.display(.noError)
        loadingView.display(ProductsLoadingViewModel(isLoading: true))
    }
    
    func didLoadProductsWith(products: [ProductItem]) {
        loadingView.display(ProductsLoadingViewModel(isLoading: false))
        productsView.display(ProductsViewModel(products: products))
    }
}

final class ProductsPresenterTests: XCTestCase {
    
    func test_init_doesNotSendMessagesToView() {
  
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty, "No view messages expexted")
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
    
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ProductsPresenter, view: ViewSpy) {
        
        let view = ViewSpy()
        let sut = ProductsPresenter(loadingView: view, productsView: view, errorView: view)
        trackForMemoryLeak(sut, file: file, line: line)
        trackForMemoryLeak(view, file: file, line: line)
        
        return (sut, view)
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
