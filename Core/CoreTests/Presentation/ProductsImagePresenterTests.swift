//
//  ProductsImagePresenterTests.swift
//  CoreTests
//
//  Created by Matteo Casu on 24/03/26.
//

import XCTest
import Core

extension Double {
    var toString: String { "\(self)" }
}

public struct ProductImageViewModel {
    let title: String
    let description: String
    let price: String
    var image: Any?
    var isLoading: Bool
    var shouldRetry: Bool
}


public protocol ProductImageView {
    func display(_ model: ProductImageViewModel)
}


class ProductImagePresenter {
    
    private let productImageView: ProductImageView
    
    init(productImageView: ProductImageView) {
        self.productImageView = productImageView
    }
    
    func didStartLoading(for model: ProductItem) {
        productImageView.display(
            ProductImageViewModel(
                title: model.title,
                description: model.description,
                price: model.price.toString,
                image: nil,
                isLoading: true,
                shouldRetry: false)
        )
    }
}

public final class ProductsImagePresenterTests: XCTestCase {
    
    
    func test_init_doesNotSendMessagesToView() {
        
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty)
    }
    
    
    func test_didStartLoading_displayLoadingImage() {
        
        let (sut, view) = makeSUT()
        let productModel = makeItem().model
        
        sut.didStartLoading(for: productModel)
        
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(view.messages.first?.title, productModel.title)
        XCTAssertEqual(view.messages.first?.description, productModel.description)
        XCTAssertEqual(view.messages.first?.price, "\(productModel.price)")
        XCTAssertNil(view.messages.first?.image)
        XCTAssertEqual(view.messages.first?.isLoading, true)
        XCTAssertEqual(view.messages.first?.shouldRetry, false)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ProductImagePresenter, view: ViewSpy) {
        
        let view = ViewSpy()
        let sut = ProductImagePresenter(productImageView: view)
        
        trackForMemoryLeak(view, file: file, line: line)
        trackForMemoryLeak(sut, file: file, line: line)
        
        return (sut, view)
    }
    
    
    private class ViewSpy: ProductImageView {
        
        
        private(set) var messages = [ProductImageViewModel]()
        
        
        func display(_ model: ProductImageViewModel) {
            messages.append(model)
        }
    }
}
