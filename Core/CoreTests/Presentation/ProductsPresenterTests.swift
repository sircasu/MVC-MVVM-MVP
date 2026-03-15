//
//  ProductsPresenterTests.swift
//  CoreTests
//
//  Created by Matteo Casu on 15/03/26.
//

import XCTest

class ProductsPresenter {
    private let view: Any
    
    init(view: Any) {
        self.view = view
    }
}

final class ProductsPresenterTests: XCTestCase {
    
    func test_init_doesNotSendMessagesToView() {
  
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty, "No view messages expexted")
    }
    
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ProductsPresenter, view: ViewSpy) {
        
        let view = ViewSpy()
        let sut = ProductsPresenter(view: view)
        trackForMemoryLeak(sut, file: file, line: line)
        trackForMemoryLeak(view, file: file, line: line)
        
        return (sut, view)
    }
    
    
    private class ViewSpy {
        
        var messages = [Any]()
    }
}
