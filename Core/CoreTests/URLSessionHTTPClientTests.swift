//
//  URLSessionHTTPClientTests.swift
//  CoreTests
//
//  Created by Matteo Casu on 31/01/26.
//

import XCTest
import Core

final class URLSessionHTTPClientTests: XCTestCase {
        
    override func tearDown() {
        super.tearDown()
        URLProtocolStub.removeStub()
    }
    
    
    func test_performRequest_performRequestWithGivenRequest() {
        
        var urlRequest = anyRequest()
        urlRequest.httpMethod = "POST"
        
        let exp = expectation(description: "Waiting for completion")

        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, urlRequest.url)
            XCTAssertEqual(request.httpMethod, urlRequest.httpMethod)
            exp.fulfill()
        }
        
        makeSUT().perform(urlRequest) { _ in }
        
        wait(for: [exp], timeout: 1)
    }
    
    
    func test_cancelPerformRequest_cancelPendingRequest() {
        
        let receivedError = resultErrorFor(taskHandler: { $0.cancel() }) as NSError?
        XCTAssertEqual(receivedError?.code, URLError.cancelled.rawValue)
    }

    
    func test_performRequest_failsOnRequestError() {
        
        let error = anyNSError()

        let receivedError = resultErrorFor((data: nil, response: nil, error: error)) as? NSError
        
        XCTAssertEqual(receivedError?.domain, error.domain)
        XCTAssertEqual(receivedError?.code, error.code)
    }
    
    
    func test_performRequest_failsOnInvalidRepresentationCase() {
        
        XCTAssertNotNil(resultErrorFor((data: nil, response: nil, error: nil)))
        XCTAssertNotNil(resultErrorFor((data: nil, response: anyURLResponse(), error: nil)))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: nil, error: nil)))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: nil, error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: nil, response: anyURLResponse(), error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: nil, response: anyHTTPURLResponse(), error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: anyURLResponse(), error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: anyHTTPURLResponse(), error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: anyURLResponse(), error: anyNSError())))
    }
    
    
    func test_performRequest_succedsOnHTTPURLResponseWithData() {
        let response = anyHTTPURLResponse()
        let data = anyData()

        let receivedValue = resultValuesFor((data: data, response: response, error: nil))
        
        XCTAssertEqual(receivedValue?.data, data)
        XCTAssertEqual(receivedValue?.response.url, response.url)
        XCTAssertEqual(receivedValue?.response.statusCode, response.statusCode)
    }
    
    
    func test_performRequest_succedsWithEmptyDataOnHTTPURLResponseWithNilData() {
        let response = anyHTTPURLResponse()
        let emptyData = emptyData()
        
        let receivedValue = resultValuesFor((data: emptyData, response: response, error: nil))
        
        XCTAssertEqual(receivedValue?.data, emptyData)
        XCTAssertEqual(receivedValue?.response.url, response.url)
        XCTAssertEqual(receivedValue?.response.statusCode, response.statusCode)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> HTTPClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        let sut = URLSessionHTTPClient(session: session)
        
        trackForMemoryLeak(sut, file: file, line: line)
        
        return sut
    }
    
    
    private func resultErrorFor(_ values: (data: Data?, response: URLResponse?, error: Error?)? = nil, taskHandler: (HTTPClientTask) -> Void = { _ in }, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        
        let result = resultFor(values, taskHandler: taskHandler, file: file, line: line)
        
        var receivedError: Error?
        
        switch result {
        case let .failure(error):
            receivedError = error

        default: XCTFail("Expected to fail, got \(result) instead.", file: file, line: line)
        }
        
        return receivedError
                    
    }
    
    
    private func resultValuesFor(_ values: (data: Data?, response: URLResponse?, error: Error?), file: StaticString = #filePath, line: UInt = #line) -> (data: Data, response: HTTPURLResponse)? {
        
        let result = resultFor(values, file: file, line: line)
        
        var receivedValues: (data: Data, response: HTTPURLResponse)?
        
        switch result {
        case let .success((receivedData, receivedResponse)):
            receivedValues = (receivedData, receivedResponse)
           
        default: XCTFail("Expected success, got \(result) instead", file: file, line: line)
        }
        
        return receivedValues
    }
    
    
    private func resultFor(_ values: (data: Data?, response: URLResponse?, error: Error?)?, taskHandler: (HTTPClientTask) -> Void = { _ in }, file: StaticString = #filePath, line: UInt = #line) -> HTTPClient.Result {
        
        values.map { URLProtocolStub.stub(data: $0, response: $1, error: $2) }
        
        let exp = expectation(description: "Waiting for completion")
        var receivedResult: HTTPClient.Result!

        taskHandler(makeSUT().perform(anyRequest()) { result in
            receivedResult = result
            exp.fulfill()
        })
        
        wait(for: [exp], timeout: 1)
        
        return receivedResult
    }
    
    
    // MARK: URLProtocol subclass
    
    private class URLProtocolStub: URLProtocol {
    
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
            let requestObserver: ((URLRequest) -> Void)?
        }
        
        private static var _stub: Stub?
        private static var stub: Stub? {
            get { return queue.sync { _stub } }
            set { queue.sync { _stub = newValue } }
        }
        
        
        private static let queue = DispatchQueue(label: "URLProtocolStub.queue")

        
        static func stub(data: Data? = nil, response: URLResponse? = nil, error: Error? = nil) {
            stub = Stub(data: data, response: response, error: error, requestObserver: nil)
        }
        
        
        static func observeRequests(observer: @escaping (URLRequest) -> Void) {
            stub = Stub(data: nil, response: nil, error: nil, requestObserver: observer)
        }

        
        static func removeStub() {
            stub = nil
        }
        
        
        override class func canInit(with request: URLRequest) -> Bool {
            return true
        }

        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            guard let stub = URLProtocolStub.stub else { return }


            if let data = stub.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = stub.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            } else {
                client?.urlProtocolDidFinishLoading(self)
            }
        
            stub.requestObserver?(request)
        }
        
        override func stopLoading() {}
    }
    

}
