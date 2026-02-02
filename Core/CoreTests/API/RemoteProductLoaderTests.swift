//
//  RemoteProductLoaderTests.swift
//  MVCTests
//
//  Created by Matteo Casu on 17/01/26.
//

import XCTest
import Core


final class RemoteProductLoaderTests: XCTestCase {
    
    func test_init_doesNotAskForProducts() {

        let (_, client) = makeSUT()
        
        XCTAssertEqual(client.messages.count, 0)
    }
    
    
    func test_getProducts_requestsProductsFromURL() {
        let (sut, client) = makeSUT()

        sut.getProducts() { _ in }
        
        XCTAssertEqual(client.requests.count, 1)
    }
    
    
    func test_getProductsTwice_requestsProductsFromURLTwice() {
        let (sut, client) = makeSUT()

        sut.getProducts() { _ in }
        sut.getProducts() { _ in }
        
        XCTAssertEqual(client.requests.count, 2)
    }
    
    
    func test_getProducts_deliversConnectivityErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(RemoteProductsLoader.Error.connectivity)) {
            client.completeWithError(anyNSError())
        }
    }

    
    func test_getProducts_deliverInvalidDataErrorOnNon200HTTPStatusCode() {
        let (sut, client) = makeSUT()
        
        let notValidStatusCodes = [199, 201, 300, 400, 500]
        
        notValidStatusCodes.enumerated().forEach { (index, code) in
        
            expect(sut, toCompleteWith: .failure(RemoteProductsLoader.Error.invalidData)) {
                client.complete(withStatusCode: code, at: index)
            }
        }
    }
    
    
    func test_getProducts_deliverInvalidDataErrorOn200HTTPStatusCodeInvalidJSONData() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: .failure(RemoteProductsLoader.Error.invalidData)) {
            let invalidData = makeInvalidJSON()
            client.complete(withStatusCode: 200, data: invalidData)
        }
    }
    
    
    func test_getProducts_deliversEmptyDataOn200HTTPStatusCodeWithEmptyJSONListData() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: .success([])) {
            let emptyData = makeEmptyJSON()
            client.complete(withStatusCode: 200, data: emptyData)
        }
    }
    
    
    func test_getProducts_doesNotDeliverResultAfterSUTHasBeenDeallocated() {
        let anyURL = anyURL()
        let client = HTTPClientSpy()
        var sut: RemoteProductsLoader? = RemoteProductsLoader(url: anyURL, client: client)
        
        var receivedResults = [ProductsLoader.Result]()
        sut?.getProducts { receivedResults.append($0) }
        
        sut = nil
        
        client.complete(withStatusCode: 200, data: makeItemsJSON([]))
        
        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    
    func test_getProducts_deliversItemsOnProductOn200HTTPStatusCodeWithValidJSONListData() {
        let product1 = makeItem(title: "a product 1", price: 12.0, description: "a description 1")
        let product2 = makeItem(title: "a product 2", price: 4.88, description: "a description 2")
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: .success([product1.model, product2.model])) {
            let json = makeItemsJSON([product1.json, product2.json])
            client.complete(withStatusCode: 200, data: json)
        }
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteProductsLoader, client: HTTPClientSpy) {
        let url = URL(string: "http://any-url")!
        let client = HTTPClientSpy()
        let sut = RemoteProductsLoader(url: url, client: client)
        
        trackForMemoryLeak(sut, file: file, line: line)
        trackForMemoryLeak(client, file: file, line: line)
        
        return (sut, client)
    }
    
    func expect(_ sut: RemoteProductsLoader, toCompleteWith expectedResult : ProductsLoader.Result, when action: (() -> Void), file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "Waiting for load to complete")
        
        sut.getProducts() { receivedResult in

            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default: XCTFail("Expected result \(expectedResult) but got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func makeInvalidJSON() -> Data {
        Data("invalid json".utf8)
    }
    
    private func makeEmptyJSON() -> Data {
        Data("[]".utf8)
    }
    

    
    private func makeItem(id: Int = UUID().hashValue, title: String = "a product", price: Double = 3.33, description: String = "a description", category: String = "a category", image: URL = URL(string: "https://any-image-url.com")!) -> (model: ProductItem, json: [String: Any]) {
        
        let model = ProductItem(id: id, title: title, price: price, description: description, category: category, image: image)
        
        let json = [
            "id": model.id,
            "title": model.title,
            "price": model.price,
            "description": model.description,
            "category": model.category,
            "image": model.image.absoluteString
        ] as [String : Any]
        
        return (model, json)
    }
    
    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        let json = items
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
}

class HTTPClientSpy: HTTPClient {

    private struct Task: HTTPClientTask {
        let callback: () -> Void
        func cancel() {
            callback()
        }
    }
    
    var messages = [(request: URLRequest, completion: (HTTPClient.Result) -> Void)]()
    
    var requests: [URLRequest] {
        messages.map { $0.request }
    }
    
    var cancelledURLs = [URL]()
    
    func perform(_ request: URLRequest, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        messages.append((request, completion))
        return Task { [weak self] in
            self?.cancelledURLs.append(request.url!)
        }
    }
    
    func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0) {
        let response = HTTPURLResponse(url: messages[index].request.url!, statusCode: code, httpVersion: nil, headerFields: nil)!
        
        messages[index].completion(.success((data, response)))
    }
    
    func completeWithError(_ error: Error, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }

}
