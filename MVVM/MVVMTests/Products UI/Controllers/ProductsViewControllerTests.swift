//
//  ProductsViewControllerTests.swift
//  MVCTests
//
//  Created by Matteo Casu on 07/12/25.
//

import XCTest
import UIKit
import Core
import MVVM

class ProductsViewControllerTests: XCTestCase {
    
    func test_loadProductsAction_requestProductsFromLoader() {
        
        let (sut, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadProductCallCount, 0, "Expected no loading requests before the view appears")
        
        sut.simulateAppearance()
        XCTAssertEqual(loader.loadProductCallCount, 1, "Expected a loading request once view is appeared")

        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadProductCallCount, 2, "Expected another loading request once user initiates reload")
    
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadProductCallCount, 3, "Expected a third loading request once user initiates reload")
    }
    
    
    func test_loadProductsAction_runsAutomaticallyOnlyOnFirstAppearance() {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadProductCallCount, 0, "Expected no loading requests before view appears")

        sut.simulateAppearance()
        XCTAssertEqual(loader.loadProductCallCount, 1, "Expected a loading request once view appears")

        sut.simulateAppearance()
        XCTAssertEqual(loader.loadProductCallCount , 1, "Expected no loading request the second time view appears")
    }
    
    
    func test_loadingProductsIndicator_isVisibleWhileLoadingProducts() {
        
        let (sut, loader) = makeSUT()
        sut.simulateAppearance()
        
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is appeared")

        
        loader.completesProductsLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading is completed")


        sut.simulateUserInitiatedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates reload")
        
        
        loader.completesProductsLoading(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once reload is completed")
        
        
        sut.simulateUserInitiatedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates reload")
        
        
        loader.completesProductsLoadingWithError(at: 2)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once reload is completed with error")
    }
    
    
    func test_loadProductsCompletion_rendersSuccessfullyLoadedProducts() {
        let product0 = makeProduct()
        let product1 = makeProduct(title: "a product 2", price: 12.0, description: "a description 2")
        let product2 = makeProduct(title: "a product 3", price: 4.88, description: "a description 3")
        let (sut, loader) = makeSUT()
        
        
        sut.simulateAppearance()
        assertThat(sut, isRendering: [])

        
        loader.completesProductsLoading(with: [product0], at: 0)
        assertThat(sut, isRendering: [product0])

        
        sut.simulateUserInitiatedReload()
        loader.completesProductsLoading(with: [product0, product1, product2], at: 1)
        assertThat(sut, isRendering: [product0, product1, product2])

    }
    
    
    func test_loadProductCompletion_doesNotAlterCurrentRenderingStateOnError() {
        
        let product0 = makeProduct()
        let product1 = makeProduct(title: "a product 2", price: 12.0, description: "a description 2")
        let (sut, loader) = makeSUT()

        
        sut.simulateAppearance()
        assertThat(sut, isRendering: [])
        
        
        loader.completesProductsLoading(with: [product0, product1], at: 0)
        assertThat(sut, isRendering: [product0, product1])
        
        
        sut.simulateUserInitiatedReload()
        loader.completesProductsLoadingWithError(at: 1)
        assertThat(sut, isRendering: [product0, product1])
    }
    
    
    func test_productView_loadsImageURLWhenVisible() {
        
        let product0 = makeProduct(image: URL(string: "https://any-url-0.com")!)
        let product1 = makeProduct(image: URL(string: "https://any-url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completesProductsLoading(with: [product0, product1], at: 0)
        
        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image URL requests until views become visible")
        
        
        sut.simulateProductImageBeginVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [product0.image], "Expected first image URL request once first view become visible")
        
        
        sut.simulateProductImageBeginVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [product0.image, product1.image], "Expected second image URL request once second view become visible")
    }
        
    
    func test_productView_cancelImageLoadingWhenNotVisibleAnymore() {
        
        let product0 = makeProduct(image: URL(string: "https://any-url-0.com")!)
        let product1 = makeProduct(image: URL(string: "https://any-url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completesProductsLoading(with: [product0, product1], at: 0)
        
        XCTAssertEqual(loader.cancelledImageURLs, [], "Expected no cancelled image URL requests until image is not visible")
        
        
        sut.simulateProductImageNotVisible(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [product0.image], "Expected one cancelled image URL once first image become is not visible anymore")
        
        
        sut.simulateProductImageNotVisible(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [product0.image, product1.image], "Expected two cancelled image URL once second image become is not visible anymore")
    }
    
    
    func test_productViewLoadingIndicator_isVisibleWhileLoadingImage() {
        
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completesProductsLoading(with: [makeProduct(), makeProduct()], at: 0)
        
        let view0 = sut.simulateProductImageBeginVisible(at: 0)
        let view1 = sut.simulateProductImageBeginVisible(at: 1)
        
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, true, "Expect loading indicator for first view when loading first image")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true, "Expect loading indicator for second view when loading second image")
        
        
        loader.completeImageLoading(at: 0)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Expect no loading indicator for first view once loading first image completes successfully")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true, "Expect no loading indicator state change for second view once loading first image completes successfully")
        
        
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Expect no loading indicator state change on first view once loading second image completes with error")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, false, "Expect no loading indicator for second view once loading second image completes with error")
    }
    
    
    func test_productView_rendersImageLoadedFromURL() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completesProductsLoading(with: [makeProduct(), makeProduct()], at: 0)
        
        let view0 = sut.simulateProductImageBeginVisible(at: 0)
        let view1 = sut.simulateProductImageBeginVisible(at: 1)
        
        
        XCTAssertEqual(view0?.renderedImage, .none, "Expected no image for first view while loading first image")
        XCTAssertEqual(view1?.renderedImage, .none, "Expected no image for second view while loading second image")
        
        
        let imageData0 = UIImage.make(withColor: UIColor.red).pngData()!
        loader.completeImageLoading(with: imageData0, at: 0)
        
        XCTAssertEqual(view0?.renderedImage, imageData0, "Expected  image for first view on loading first image completes successfully")
        XCTAssertEqual(view1?.renderedImage, .none, "Expected no image for second view on loading first image completes successfully")
        
        
        let imageData1 = UIImage.make(withColor: UIColor.blue).pngData()!
        loader.completeImageLoading(with: imageData1, at: 1)
        
        XCTAssertEqual(view0?.renderedImage, imageData0, "Expected no image state change for first view on loading second image completes successfully")
        XCTAssertEqual(view1?.renderedImage, imageData1, "Expected image for second view on loading second image completes successfully")
    }
    
    
    func test_productViewRetryAction_isVisibleOnImageURLLoadError() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completesProductsLoading(with: [makeProduct(), makeProduct()], at: 0)
        
        let view0 = sut.simulateProductImageBeginVisible(at: 0)
        let view1 = sut.simulateProductImageBeginVisible(at: 1)
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action for first view while loading firt image")
        XCTAssertEqual(view1?.isShowingRetryAction, false, "Expected no retry action for second view while loading second image")
        
        
        let imageData0 = UIImage.make(withColor: UIColor.red).pngData()!
        loader.completeImageLoading(with: imageData0, at: 0)
        
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action for first view on loading first image completes successfully")
        XCTAssertEqual(view1?.isShowingRetryAction, false, "Expected no retry action for second view on loading first image completes successfully")
        
        
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expect no retry action state change on first view once loading second image completes with error")
        XCTAssertEqual(view1?.isShowingRetryAction, true, "Expect retry action for second view once loading second image completes with error")
    }
    
        
    
    func test_productViewRetryAction_isVisibleOnInvalidImageData() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completesProductsLoading(with: [makeProduct()], at: 0)
        
        let view0 = sut.simulateProductImageBeginVisible(at: 0)
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action while loading image")

        let invalidImageData0 = Data("invalid image data".utf8)
        loader.completeImageLoading(with: invalidImageData0, at: 0)
        
        XCTAssertEqual(view0?.isShowingRetryAction, true, "Expected  retry action for view on loading image completes successfully with invalid image")
    }
    
    
    func test_productViewRetryAction_retriesImageLoad() {
        let product0 = makeProduct(image: URL(string: "https://any-url-0.com")!)
        let product1 = makeProduct(image: URL(string: "https://any-url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completesProductsLoading(with: [product0, product1], at: 0)
        
        let view0 = sut.simulateProductImageBeginVisible(at: 0)
        let view1 = sut.simulateProductImageBeginVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [product0.image, product1.image], "Expected two image URL request for the two visible views")
        
        loader.completeImageLoadingWithError(at: 0)
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(view0?.isShowingRetryAction, true, "Expect retry action for second view once loading second image completes with error")
        XCTAssertEqual(view1?.isShowingRetryAction, true, "Expect retry action for second view once loading second image completes with error")
        
        view0?.simulateRetryAction()
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, true, "Expect loading indicator for first view when loading first image after retry action")
        XCTAssertEqual(loader.loadedImageURLs, [product0.image, product1.image, product0.image], "Expected three image URL request after firt view retry action")
        
        view1?.simulateRetryAction()
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true, "Expect loading indicator for second view when loading second image after retry action")
        XCTAssertEqual(loader.loadedImageURLs, [product0.image, product1.image, product0.image, product1.image], "Expected four image URL request after second view retry action")
        
    }
    
    
    func test_productView_preloadsImageURLWhenNearVisible() {
        let product0 = makeProduct(image: URL(string: "https://any-url-0.com")!)
        let product1 = makeProduct(image: URL(string: "https://any-url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completesProductsLoading(with: [product0, product1], at: 0)
        
        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image URL requests until image is near visible")
        
        sut.simulateProductImageNearVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [product0.image], "Expected first image URL request once first image is near visible")
        
        sut.simulateProductImageNearVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [product0.image, product1.image], "Expected second image URL request once second image is near visible")
    }
        
    
    func test_productView_cancelsImageURLReloadWhenNotNearVisibleAnymore() {
        let product0 = makeProduct(image: URL(string: "https://any-url-0.com")!)
        let product1 = makeProduct(image: URL(string: "https://any-url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completesProductsLoading(with: [product0, product1], at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [], "Expected no cancelled image URL requests until image is not near visible")
        
        sut.simulateProductImageNotNearVisibleAnymore(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [product0.image], "Expected first cancelled image URL request once first image is not near visible anymore")
        
        sut.simulateProductImageNotNearVisibleAnymore(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [product0.image, product1.image], "Expected second cancelled image URL request once second image is not near visible anymore")
    }
    
    
    func test_productView_reloadsImageURLWhenBecomingVisibleAgain() {
        let product0 = makeProduct(image: URL(string: "https://any-url-0.com")!)
        let product1 = makeProduct(image: URL(string: "https://any-url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completesProductsLoading(with: [product0, product1], at: 0)


        sut.simulateProductBecomingVisibleAgain(at: 0)
        
        XCTAssertEqual(loader.loadedImageURLs, [product0.image, product0.image], "Expected two image URL request after first view becomes visible again")
        
        sut.simulateProductBecomingVisibleAgain(at: 1)

        XCTAssertEqual(loader.loadedImageURLs, [product0.image, product0.image, product1.image, product1.image], "Expected two new image URL request after second view becomes visible again")
    }
    
    
    func test_productView_doesNotRenderImageWhenNotVisibleAnymore() {
        
        let (sut, loader) = makeSUT()

        
        sut.simulateAppearance()
        loader.completesProductsLoading(with: [makeProduct()], at: 0)
        
        let view = sut.simulateProductImageNotVisible(at: 0)
        
        loader.completeImageLoading(with: UIImage.make(withColor: .red).pngData()!)
        
        XCTAssertNil(view?.renderedImage, "Expected no rendered image when an image load finishes after the view is not visible anymore")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ProductsViewController, loader: LoaderSpy) {
        
        let loader = LoaderSpy()
        let sut = ProductsUIComposer.makeProductsUI(productsLoader: loader, imageLoader: loader)
        trackForMemoryLeak(sut, file: file, line: line)
        trackForMemoryLeak(loader, file: file, line: line)
        
        return (sut, loader)
    }
    
    private func makeProduct(id: Int = UUID().hashValue, title: String = "a product", price: Double = 3.33, description: String = "a description", category: String = "a category", image: URL = URL(string: "https://any-image-url.com")!) -> ProductItem {
        
        ProductItem(id: id, title: title, price: price, description: description, category: category, image: image)
    }
    
    
    func assertThat(_ sut: ProductsViewController, isRendering items: [ProductItem], file: StaticString = #filePath, line: UInt = #line) {
        
        guard items.count == sut.numberOfRenderedProductViews else {
            XCTFail("Expected \(items.count) got \(sut.numberOfRenderedProductViews) instead", file: file, line: line)
            return
        }
        XCTAssertEqual(sut.numberOfRenderedProductViews, items.count, file: file, line: line)
        
        
        items.enumerated().forEach { (index, item) in
            assertThat(sut, hasViewConfiguredFor: item, at: index, file: file, line: line)
        }
    }
    
    
    func assertThat(_ sut: ProductsViewController, hasViewConfiguredFor product: ProductItem, at index: Int, file: StaticString = #filePath, line: UInt = #line) {
        
        let view = sut.productView(at: index)
        
        guard let cell = view as? ProductCell else {
            XCTFail("Expected \(ProductCell.self) instance but got \(String(describing: view)) indstead", file: file, line: line)
            return
        }
        
        XCTAssertNotNil(cell)
        XCTAssertEqual(cell.titleText, product.title, file: file, line: line)
        XCTAssertEqual(cell.descriptionText, product.description, file: file, line: line)
        XCTAssertEqual(cell.priceText, "\(product.price)", file: file, line: line)
    }

}
