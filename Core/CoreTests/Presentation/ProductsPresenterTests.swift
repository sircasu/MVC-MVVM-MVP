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
        
        let view = ViewSpy()
        let _ = ProductsPresenter(view: view)
        
        XCTAssertTrue(view.messages.isEmpty, "No view messages expexted")
    }
    
    
    
    private class ViewSpy {
        
        var messages = [Any]()
    }
}
