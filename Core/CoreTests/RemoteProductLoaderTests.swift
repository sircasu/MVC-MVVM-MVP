//
//  RemoteProductLoaderTests.swift
//  MVCTests
//
//  Created by Matteo Casu on 17/01/26.
//

import XCTest
import Core

class RemoteProductLoader {
    
    let url: URL
    let loader: HTTPClientSpy
    
    init(url: URL, loader: HTTPClientSpy) {
        self.url = url
        self.loader = loader
    }
    
    func load() {
        loader.load()
    }
}


final class RemoteProductLoaderTests: XCTestCase {
    
    func test_init_doesNotAskForProducts() {

        let (_, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    
    func test_load_requestsDataFromURL() {
        let (sut, loader) = makeSUT()

        sut.load()
        
        XCTAssertEqual(loader.loadCallCount, 1)
    }
    
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteProductLoader, loader: HTTPClientSpy) {
        let url = URL(string: "http://any-url")!
        let loader = HTTPClientSpy()
        let sut = RemoteProductLoader(url: url, loader: loader)
        
        trackForMemoryLeak(loader, file: file, line: line)
        trackForMemoryLeak(sut, file: file, line: line)
        
        return (sut, loader)
    }
}

class HTTPClientSpy {
    var loadCallCount = 0
    
    func load() {
        loadCallCount += 1
    }
}
