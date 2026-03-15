//
//  ProductsPresenterTests.swift
//  CoreTests
//
//  Created by Matteo Casu on 15/03/26.
//

import XCTest

struct ProductsErrorViewModel {
    let message: String?
    
    static var noError: ProductsErrorViewModel {
        ProductsErrorViewModel(message: nil)
    }
}

protocol ProductsErrorView {
    func display(_ viewModel: ProductsErrorViewModel)
}

class ProductsPresenter {
    private let errorView: ProductsErrorView
    
    init(errorView: ProductsErrorView) {
        self.errorView = errorView
    }
    
    func didStartLoading() {
        errorView.display(.noError)
    }
}

final class ProductsPresenterTests: XCTestCase {
    
    func test_init_doesNotSendMessagesToView() {
  
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty, "No view messages expexted")
    }
    
    
    func test_didStartLoading_displayNoErrorMessage() {
        
        let (sut, view) = makeSUT()
        
        sut.didStartLoading()
        
        XCTAssertEqual(view.messages, [.display(errorMessage: .none)])
    }
    
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ProductsPresenter, view: ViewSpy) {
        
        let view = ViewSpy()
        let sut = ProductsPresenter(errorView: view)
        trackForMemoryLeak(sut, file: file, line: line)
        trackForMemoryLeak(view, file: file, line: line)
        
        return (sut, view)
    }
    
    
    private class ViewSpy: ProductsErrorView {
        
        enum Message: Equatable {
            case display(errorMessage: String?)
        }
        
        private(set) var messages = [Message]()
        
        
        func display(_ viewModel: ProductsErrorViewModel) {
            messages.append(.display(errorMessage: viewModel.message))
        }
    }
}
