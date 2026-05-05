//
//  ProductsImagePresenterTests.swift
//  CoreTests
//
//  Created by Matteo Casu on 24/03/26.
//

import XCTest
import Core

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
    
    
    func test_didFinishLoadingData_displayRetryOnFailedImageTransformation() {
        let (sut, view) = makeSUT(imageTransformer: fail)
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
    
    
    func test_didFinishLoadingData_displaysImageOnSuccessfulTransformation() {
        let data = anyData()
        let productModel = makeItem().model
        
        let transformedData = AnyImage()
        let (sut, view) = makeSUT(imageTransformer: { _ in transformedData })
        
        sut.didFinishLoadingData(with: data, for: productModel)
        
        let message = view.messages.first
        
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.description, productModel.description)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.shouldRetry, false)
        XCTAssertEqual(message?.image, transformedData)
    }
    
    
    func test_didFinishLoadingDataWithError_displaysRetry() {
        let productModel = makeItem().model
        let (sut, view) = makeSUT()
        
        sut.didFinishLoadingData(with: anyNSError(), for: productModel)
        
        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.description, productModel.description)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.shouldRetry, true)
        XCTAssertNil(message?.image)
    }
    
    
    
    // MARK: - Helpers
    
    private func makeSUT(
        imageTransformer: @escaping (Data) -> AnyImage? = { _ in nil },
        file: StaticString = #filePath,
        line: UInt = #line) -> (sut: ProductImagePresenter<ViewSpy, AnyImage>, view: ViewSpy) {
        
        let view = ViewSpy()
        let sut = ProductImagePresenter(productImageView: view, imageTransformer: imageTransformer)
        
        trackForMemoryLeak(view, file: file, line: line)
        trackForMemoryLeak(sut, file: file, line: line)
        
        return (sut, view)
    }
    
    
    private var fail: (Data) -> AnyImage? {
        { _ in nil }
    }
    
    private struct AnyImage: Equatable {}
    
    
    
    private class ViewSpy: ProductImageView {
        
        
        private(set) var messages = [ProductImageViewModel<AnyImage>]()
        
        
        func display(_ model: ProductImageViewModel<AnyImage>) {
            messages.append(model)
        }
    }
}
