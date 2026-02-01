//
//  RemoteProductImageDataLoaderTests.swift
//  CoreTests
//
//  Created by Matteo Casu on 01/02/26.
//

import XCTest
import Core

final class RemoteProductImageDataLoader {
    
    let client: HTTPClientSpy
    
    init(client: HTTPClientSpy) {
        self.client = client
    }
    
    func loadImageData(from url: URL, completion: @escaping (ProductImageLoader.Result) -> Void) {
        let urlRequest = URLRequest(url: url)
        client.perform(urlRequest) { result in
        
            switch result {
            case .success : break
            case let .failure(error):
                completion(.failure(error))
            }

        }
    }
}

final class RemoteProductImageDataLoaderTests: XCTestCase {
    
    func test_init_doesNotPerformURLRequest() {
        
        let (_, client) = makeSUT()
        
        XCTAssertEqual(client.requests.count, 0)
    }
        
    
    func test_loadImageDataFromURL_requestsDataFromURL() {
        
        let (sut, client) = makeSUT()
        
        sut.loadImageData(from: anyURL()) { _ in }
        
        XCTAssertEqual(client.requests.count, 1)
    }        
    
    
    func test_loadImageDataFromURL_deliversErrorOnClientError() {
        
        let (sut, client) = makeSUT()
        
        let error = anyNSError()
        
        let exp = expectation(description: "Wait for completion")
        var receivedError: NSError?
        sut.loadImageData(from: anyURL()) { result in
           
            switch result {
            case let .failure(error):
                receivedError = error as NSError
            default: XCTFail("Expected error got \(result) instead")
            }
            exp.fulfill()
        }
        
        client.completeWithError(anyNSError())
        
        wait(for: [exp], timeout: 1)

        XCTAssertEqual(receivedError, error)
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
