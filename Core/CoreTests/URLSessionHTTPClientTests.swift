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
    
    func perform(_ request: URLRequest, completion: @escaping (HTTPClient.Result) -> Void ) {
        
        session.dataTask(with: request) { _, _, error in
            if let error {
                completion(.failure(error))
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

    func test_performRequest_failsOnRequestError() {
        
        let urlRequest = URLRequest(url: anyURL())
        let error = anyNSError()
        URLProtocolStub.stub(request: urlRequest, error: error)
        
        let sut = URLSessionHTTPClient()
        
        let exp = expectation(description: "Waiting for completion")
        sut.perform(urlRequest) { result in
            
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
    
    // MARK: Helpers
    
    private class URLProtocolStub: URLProtocol {
      
        private static var stubs = [URLRequest: Stub]()
        
        private struct Stub {
            let error: Error?
        }
        
        static func stub(request: URLRequest, error: Error? = nil) {
            stubs[request] = Stub(error: error)
        }
        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stubs = [:]
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            guard let _ = URLProtocolStub.stubs[request] else { return false }
            
            return true
        }

        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            guard let stub = URLProtocolStub.stubs[request] else { return }
            
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
    }
    

}
