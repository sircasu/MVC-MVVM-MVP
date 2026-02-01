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
    
    
    public enum Error: Swift.Error {
        case invalidData
    }
    
    
    func loadImageData(from url: URL, completion: @escaping (ProductImageLoader.Result) -> Void) {
        let urlRequest = URLRequest(url: url)
        client.perform(urlRequest) { result in
        
            switch result {
            case .success: completion(.failure(Error.invalidData))
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
        
        expect(sut, toCompleteWith: .failure(error)) {
            client.completeWithError(error)
        }
    }
        
    
    func test_loadImageDataFromURL_deliversInvalidDataErrorOnNon200HTTPStatusCode() {
        
        let (sut, client) = makeSUT()
        
        let notValidStatusCodes = [199, 201, 300, 400, 500]
        
        notValidStatusCodes.enumerated().forEach { (index, code) in
        
            expect(sut, toCompleteWith: .failure(RemoteProductImageDataLoader.Error.invalidData)) {
                client.complete(withStatusCode: code, at: index)
            }
        }
    }        
    
    func test_loadImageDataFromURL_deliversInvalidDataErrorOn200HTTPStatusCodeWithEmptyData() {
        
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: .failure(RemoteProductImageDataLoader.Error.invalidData)) {
            client.complete(withStatusCode: 200, data: emptyData())
        }
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteProductImageDataLoader, client: HTTPClientSpy) {
        
        let client = HTTPClientSpy()
        let sut = RemoteProductImageDataLoader(client: client)
        
        trackForMemoryLeak(sut, file: file, line: line)
        trackForMemoryLeak(client, file: file, line: line)
        
        return (sut, client)
    }
    
    private func expect(_ sut: RemoteProductImageDataLoader, toCompleteWith expectedResult: ProductImageLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "Wait for completion")

        sut.loadImageData(from: anyURL()) { result in
           
            switch (result, expectedResult) {
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default: XCTFail("Expected error got \(result) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
 
        wait(for: [exp], timeout: 1)
    }
}
