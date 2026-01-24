//
//  RemoteProductLoaderTests.swift
//  MVCTests
//
//  Created by Matteo Casu on 17/01/26.
//

import XCTest
import Core

protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    func perform(_ request: URLRequest, completion: @escaping (Result) -> Void)
}


class RemoteProductLoader {
    
    let url: URL
    let client: HTTPClient
    
    
    public enum Error: Swift.Error {
        case invalidData
        case connectivity
    }
    
    
    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    func getProducts(completion: @escaping (ProductsLoader.Result) -> Void) {
        
        client.perform(URLRequest(url: url)) { [weak self] result in
            
            guard self != nil else { return }
            
            switch result {
            case let .success((data, response)):
                if response.statusCode != 200 {
                    completion(.failure(Error.invalidData))
                } else if response.statusCode == 200, let items = try? JSONDecoder().decode([RemoteProductItem].self, from: data) {
                    completion(.success(items.map { $0.toProductItem }))
                } else {
                    completion(.failure(Error.invalidData))
                }
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
}



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
        
        expect(sut, toCompleteWith: .failure(RemoteProductLoader.Error.connectivity)) {
            client.completeWithError(NSError(domain: "test", code: 0))
        }
    }

    
    func test_getProducts_deliverInvalidDataErrorOnNon200HTTPStatusCode() {
        let (sut, client) = makeSUT()
        
        let notValidStatusCodes = [199, 201, 300, 400, 500]
        
        notValidStatusCodes.enumerated().forEach { (index, code) in
        
            expect(sut, toCompleteWith: .failure(RemoteProductLoader.Error.invalidData)) {
                client.complete(withStatusCode: code, at: index)
            }
        }
    }
    
    
    func test_getProducts_deliverInvalidDataErrorOn200HTTPStatusCodeInvalidJSONData() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: .failure(RemoteProductLoader.Error.invalidData)) {
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
        let anyURL = URL(string: "https://any-url.com")!
        let client = HTTPClientSpy()
        var sut: RemoteProductLoader? = RemoteProductLoader(url: anyURL, client: client)
        
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
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteProductLoader, client: HTTPClientSpy) {
        let url = URL(string: "http://any-url")!
        let client = HTTPClientSpy()
        let sut = RemoteProductLoader(url: url, client: client)
        
        trackForMemoryLeak(sut, file: file, line: line)
        trackForMemoryLeak(client, file: file, line: line)
        
        return (sut, client)
    }
    
    func expect(_ sut: RemoteProductLoader, toCompleteWith expectedResult : ProductsLoader.Result, when action: (() -> Void), file: StaticString = #filePath, line: UInt = #line) {
        
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

    var messages = [(request: URLRequest, completion: (HTTPClient.Result) -> Void)]()
    
    var requests: [URLRequest] {
        messages.map { $0.request }
    }
    
    func perform(_ request: URLRequest, completion: @escaping (HTTPClient.Result) -> Void) {
        messages.append((request, completion))
    }
    
    func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0) {
        let response = HTTPURLResponse(url: messages[index].request.url!, statusCode: code, httpVersion: nil, headerFields: nil)!
        
        messages[index].completion(.success((data, response)))
    }
    
    func completeWithError(_ error: Error, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }
}
