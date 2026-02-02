//
//  RemoteProductImageDataLoaderTests.swift
//  CoreTests
//
//  Created by Matteo Casu on 01/02/26.
//

import XCTest
import Core

final class RemoteProductImageDataLoader {
    
    let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    
    public enum Error: Swift.Error {
        case invalidData
        case connectivity
    }
    
    
    private final class HTTPClientTaskWrapper: ImageLoaderTask {
        
        private var completion: ((ProductImageLoader.Result) -> Void)?
        var wrapped: HTTPClientTask?
        
        init(_ completion: @escaping (ProductImageLoader.Result) -> Void) {
            self.completion = completion
        }
        
        func complete(with result: ProductImageLoader.Result) {
            completion?(result)
        }
        
        func cancel() {
            preventFurtherCompletion()
            wrapped?.cancel()
        }
        
        private func preventFurtherCompletion() {
            completion = nil
        }
    }
    
    
    func loadImageData(from url: URL, completion: @escaping (ProductImageLoader.Result) -> Void) -> ImageLoaderTask {
       
        let urlRequest = URLRequest(url: url)
        
        let task = HTTPClientTaskWrapper(completion)
        task.wrapped = client.perform(urlRequest) { [weak self] result in
            
            guard self != nil else { return }
        
            switch result {
            case let .success((data, response)):
                if response.statusCode == 200, !data.isEmpty {

                    task.complete(with: .success(data))
                } else {
                    task.complete(with: .failure(RemoteProductImageDataLoader.Error.invalidData))
                }
                
            case .failure:
                task.complete(with: .failure(RemoteProductImageDataLoader.Error.connectivity))
            }

        }
        
        return task
    }
}

final class RemoteProductImageDataLoaderTests: XCTestCase {
    
    func test_init_doesNotPerformURLRequest() {
        
        let (_, client) = makeSUT()
        
        XCTAssertEqual(client.requests.count, 0)
    }
        
    
    func test_loadImageDataFromURL_requestsDataFromURL() {
        
        let (sut, client) = makeSUT()
        
        _ = sut.loadImageData(from: anyURL()) { _ in }
        
        XCTAssertEqual(client.requests.count, 1)
    }        
    
    
    func test_loadImageDataFromURL_deliversConnectivityErrorOnClientError() {
        
        let (sut, client) = makeSUT()
        let error = anyNSError()
        
        expect(sut, toCompleteWith: .failure(RemoteProductImageDataLoader.Error.connectivity)) {
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
        
    
    func test_loadImageDataFromURL_deliversNonEmptyDataOn200HTTPResponse() {
        
        let (sut, client) = makeSUT()
        let nonEmptyData = anyData()
        
        expect(sut, toCompleteWith: .success(nonEmptyData)) {
            client.complete(withStatusCode: 200, data: nonEmptyData)
        }
    }
    
    
    func test_cancelLoadImageDataFromURL_cancelsClientURLRequest() {
        let (sut, client) = makeSUT()
        let url = anyURL()
        
        let task = sut.loadImageData(from: url) { _ in }
        XCTAssertTrue(client.cancelledURLs.isEmpty, "Expected no cancelledURLs until task is cancelled")
        
        task.cancel()
        XCTAssertEqual(client.cancelledURLs, [url], "Expected cancelled URL after task is cancelled")
    }
    
    
    func test_loadImageDataFromURL_doesNotDeliverResultAfterCancellingTask() {
        let (sut, client) = makeSUT()
        
        var received = [ProductImageLoader.Result]()
        let task = sut.loadImageData(from: anyURL()) { received.append($0) }
        task.cancel()
        
        client.complete(withStatusCode: 200, data: anyData())
        client.complete(withStatusCode: 403, data: emptyData())
        client.completeWithError(anyNSError())
        
        XCTAssertTrue(received.isEmpty, "Expected no received results after task is cancelled")
    }
    
    
    func test_loadImageDataFromURL_doesNotDeliverResultAfterSUTHasBeenDeallocated() {
        
        let anyURL = anyURL()
        let client = HTTPClientSpy()
        var sut: RemoteProductImageDataLoader? = RemoteProductImageDataLoader(client: client)
        
        var receivedResults = [ProductImageLoader.Result]()
        _ = sut?.loadImageData(from: anyURL) { receivedResults.append($0) }
        
        sut = nil
        
        client.complete(withStatusCode: 200, data: anyData())
        
        XCTAssertTrue(receivedResults.isEmpty)
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

        _ = sut.loadImageData(from: anyURL()) { result in
           
            switch (result, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default: XCTFail("Expected \(expectedResult) got \(result) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
 
        wait(for: [exp], timeout: 1)
    }
}
