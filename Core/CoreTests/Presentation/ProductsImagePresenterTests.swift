//
//  ProductsImagePresenterTests.swift
//  CoreTests
//
//  Created by Matteo Casu on 24/03/26.
//

import XCTest


class ProductImagePresenter {
    
    var view: Any
    
    init(view: Any) {
        self.view = view
    }
}

public final class ProductsImagePresenterTests: XCTestCase {
    
    
    func test_init_doesNotSendMessagesToView() {
        
        let (_, spy) = makeSUT()
        
        XCTAssertTrue(spy.messages.isEmpty)
    }
    
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ProductImagePresenter, spy: ViewSpy) {
        
        let spy = ViewSpy()
        let sut = ProductImagePresenter(view: spy)
        
        trackForMemoryLeak(spy, file: file, line: line)
        trackForMemoryLeak(sut, file: file, line: line)
        
        return (sut, spy)
    }
    
    
    private class ViewSpy {
        var messages: [Any] = []
    }
}
