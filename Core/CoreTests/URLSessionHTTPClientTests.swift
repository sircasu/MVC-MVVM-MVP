//
//  URLSessionHTTPClientTests.swift
//  CoreTests
//
//  Created by Matteo Casu on 31/01/26.
//

import XCTest
import Core

class URLSessionHTTPClient {
    let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    
    struct UnexpectedValueRepresentation: Error {}
    
    
    func perform(_ request: URLRequest, completion: @escaping (HTTPClient.Result) -> Void ) {
        
        session.dataTask(with: request) { _, _, error in
            if let error {
                completion(.failure(error))
            } else {
                completion(.failure(UnexpectedValueRepresentation()))
            }
            

        }.resume()
    }
}

final class URLSessionHTTPClientTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequests()
    }
    
    override func tearDown() {
        super.tearDown()
        URLProtocolStub.stopInterceptingRequests()
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

    
    func test_performRequest_failsOnRequestError() {
        
        let urlRequest = anyRequest()
        let error = anyNSError()
        URLProtocolStub.stub(error: error)

        let exp = expectation(description: "Waiting for completion")
        makeSUT().perform(urlRequest) { result in
            
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError.domain, error.domain)
                XCTAssertEqual(receivedError.code, error.code)
            default: XCTFail("Expected to fail with error \(error), got \(result) instead.")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    
    func test_performRequest_failsOnDataResponseErrorNilInvalidRepresentationCase() {
        
        URLProtocolStub.stub(data: nil, response: nil, error: nil)
        let urlRequest = anyRequest()
        
        let exp = expectation(description: "Waiting for completion")
        makeSUT().perform(urlRequest) { result in
            
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertNotNil(receivedError)
               
            default: XCTFail("Expected to fail, got \(result) instead.")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> URLSessionHTTPClient {
        let sut = URLSessionHTTPClient()
        
        trackForMemoryLeak(sut, file: file, line: line)
        
        return sut
    }
    
    
    // MARK: URLProtocol subclass
    
    private class URLProtocolStub: URLProtocol {
      
        private static var stub: Stub?
        private struct Stub {
            let data: Data?
            let response: HTTPURLResponse?
            let error: Error?
        }
        static func stub(data: Data? = nil, response: HTTPURLResponse? = nil, error: Error? = nil) {
            stub = Stub(data: data, response: response, error: error)
        }
        
        
        private static var requestObserver: ((URLRequest) -> Void)?
        static func observeRequests(observer: @escaping (URLRequest) -> Void) {
            requestObserver = observer
        }
        

        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
            requestObserver = nil
        }
        
        
        override class func canInit(with request: URLRequest) -> Bool {
            return true
        }

        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            if let requestObserver = URLProtocolStub.requestObserver {
                client?.urlProtocolDidFinishLoading(self)
                return requestObserver(request)
            }
            
            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = URLProtocolStub.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = URLProtocolStub.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
        
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
    }
    

}
