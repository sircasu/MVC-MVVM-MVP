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
    private let imageTransformer: (Data) -> Any?
    
    init(productImageView: ProductImageView, imageTransformer: @escaping (Data) -> Any?) {
        self.productImageView = productImageView
        self.imageTransformer = imageTransformer
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
    
    
    private struct InvalidImageDataError: Error {}
    
    
    func didFinishLoadingData(with data: Data, for model: ProductItem) {

        productImageView.display(ProductImageViewModel(
            title: model.title,
            description: model.description,
            price: model.price.toString,
            image: imageTransformer(data),
            isLoading: false,
            shouldRetry: true))
    }
    

}

public final class ProductsImagePresenterTests: XCTestCase {
    
    
    func test_init_doesNotSendMessagesToView() {
        
        let (_, view) = makeSUT(imageTransformer: { _ in })
        
        XCTAssertTrue(view.messages.isEmpty)
    }
    
    
    func test_didStartLoading_displayLoadingImage() {
        
        let (sut, view) = makeSUT(imageTransformer: { _ in })
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
    
    
    func test_didFinishLoadingData_displayRetryOnFailedImageTransformation() {
        let (sut, view) = makeSUT(imageTransformer: { _ in nil })
        let productModel = makeItem().model
        
        sut.didFinishLoadingData(with: anyData(), for: productModel)
            
        let message = view.messages.first

        XCTAssertEqual(message?.title, productModel.title)
        XCTAssertEqual(message?.description, productModel.description)
        XCTAssertEqual(message?.price, "\(productModel.price)")
        XCTAssertNil(message?.image)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.shouldRetry, true)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(imageTransformer: @escaping (Data) -> Any?, file: StaticString = #filePath, line: UInt = #line) -> (sut: ProductImagePresenter, view: ViewSpy) {
        
        let view = ViewSpy()
        let sut = ProductImagePresenter(productImageView: view, imageTransformer: imageTransformer)
        
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
