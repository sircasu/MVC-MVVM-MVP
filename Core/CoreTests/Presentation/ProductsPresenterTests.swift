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



class ProductsPresenter {
    
    private var loadingView: ProductsLoadingView
    private let errorView: ProductsErrorView
    
    init(loadingView: ProductsLoadingView, errorView: ProductsErrorView) {
        self.loadingView    = loadingView
        self.errorView      = errorView
    }
    
    func didStartLoading() {
        errorView.display(.noError)
        loadingView.display(ProductsLoadingViewModel(isLoading: true))
    }
    
    func didLoadProductsWith(products: [ProductItem]) {
        loadingView.display(ProductsLoadingViewModel(isLoading: false))
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
    
    
    func test_didLoadProductWithProducts_displayIsLoadingFalseMessage() {
        
        let (sut, view) = makeSUT()
        
        sut.didLoadProductsWith(products: [])
        
        XCTAssertEqual(view.messages, [.display(isLoading: false)])
    }
    
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ProductsPresenter, view: ViewSpy) {
        
        let view = ViewSpy()
        let sut = ProductsPresenter(loadingView: view, errorView: view)
        trackForMemoryLeak(sut, file: file, line: line)
        trackForMemoryLeak(view, file: file, line: line)
        
        return (sut, view)
    }
    
    
    private class ViewSpy: ProductsErrorView, ProductsLoadingView{
        
        enum Message: Equatable {
            case display(errorMessage: String?)
            case display(isLoading: Bool)
        }
        
        private(set) var messages = [Message]()
        
        
        func display(_ viewModel: ProductsErrorViewModel) {
            messages.append(.display(errorMessage: viewModel.message))
        }
        
        func display(_ viewModel: ProductsLoadingViewModel) {
            messages.append(.display(isLoading: viewModel.isLoading))
        }
    }
}
