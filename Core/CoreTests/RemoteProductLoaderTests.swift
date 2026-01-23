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
    
    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    func getProducts(completion: @escaping (ProductsLoader.Result) -> Void) {
        
        client.perform(URLRequest(url: url)) { result in
            
            switch result {
            case let .failure(error):
                completion(.failure(error))
            default: break
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
    
    
    func test_load_deliversErrorOnClientError() {
        let expectedError = NSError(domain: "test", code: 0)
        let (sut, client) = makeSUT()
        
        var receivedError: NSError?
        let exp = expectation(description: "Waiting for load to complete")
        
        sut.getProducts() { result in
            switch result {
            case .success: XCTFail("Expected error got success instead")
            case let .failure(error as NSError):
                receivedError = error
            }
        
            exp.fulfill()
        }
        
        client.completeWithError(expectedError, at: 0)
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertNotNil(receivedError)
        XCTAssertEqual(receivedError, expectedError)

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
}

class HTTPClientSpy: HTTPClient {

    
    var messages = [(request: URLRequest, completion: (HTTPClient.Result) -> Void)]()
    
    var requests: [URLRequest] {
        messages.map { $0.request }
    }
    
    func perform(_ request: URLRequest, completion: @escaping (HTTPClient.Result) -> Void) {
        messages.append((request, completion))
    }
    
    
    func completeWithError(_ error: Error, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }
}
