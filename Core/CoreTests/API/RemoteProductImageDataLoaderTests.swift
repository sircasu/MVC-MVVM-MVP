//
//  RemoteProductImageDataLoaderTests.swift
//  CoreTests
//
//  Created by Matteo Casu on 01/02/26.
//

import XCTest

final class RemoteProductImageDataLoader {
    init(client: Any) {}
}

final class RemoteProductImageDataLoaderTests: XCTestCase {
    
    func test_init_doesNotPerformURLRequest() {
        
        let (_, client) = makeSUT()
        
        XCTAssertEqual(client.requestedURLs, 0)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteProductImageDataLoader, client: HTTPClientSpy) {
        
        let client = HTTPClientSpy()
        let sut = RemoteProductImageDataLoader(client: client)
        
        trackForMemoryLeak(sut, file: file, line: line)
        trackForMemoryLeak(client, file: file, line: line)
        
        return (sut, client)
    }
}
