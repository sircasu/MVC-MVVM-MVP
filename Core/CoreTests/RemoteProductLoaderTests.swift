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
    let client: HTTPClientSpy
    
    init(url: URL, client: HTTPClientSpy) {
        self.url = url
        self.client = client
    }
    
    func load() {
        
        client.perform(URLRequest(url: url)) {_ in}
    }
}


final class RemoteProductLoaderTests: XCTestCase {
    
    func test_init_doesNotAskForProducts() {

        let (_, client) = makeSUT()
        
        XCTAssertEqual(client.loadCallCount, 0)
    }
    
    
    func test_load_requestsProductsFromURL() {
        let (sut, client) = makeSUT()

        sut.load()
        
        XCTAssertEqual(client.loadCallCount, 1)
    }
    
        
    
    func test_loadTwice_requestsProductsFromURLTwice() {
        let (sut, client) = makeSUT()

        sut.load()
        sut.load()
        
        XCTAssertEqual(client.loadCallCount, 2)
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
    var loadCallCount = 0
    
    func perform(_ request: URLRequest, completion: @escaping (HTTPClient.Result) -> Void) {
        loadCallCount += 1
    }
}
