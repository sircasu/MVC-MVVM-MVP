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
        
        session.dataTask(with: request) { data, response, error in
            if let error {
                completion(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success((data, response)))
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
        
        let error = anyNSError()

        let receivedError = resultErrorFor(data: nil, response: nil, error: error) as? NSError
        
        XCTAssertEqual(receivedError?.domain, error.domain)
        XCTAssertEqual(receivedError?.code, error.code)
    }
    
    
    func test_performRequest_failsOnInvalidRepresentationCase() {
        
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyURLResponse(), error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyURLResponse(), error: anyNSError()))
    }
    
    
    func test_performRequest_succedsOnHTTPURLResponseWithData() {
        let response = anyHTTPURLResponse()
        let data = anyData()

        let receivedValue = resultValuesFor(data: data, response: response, error: nil)
        
        XCTAssertEqual(receivedValue?.data, data)
        XCTAssertEqual(receivedValue?.response.url, response.url)
        XCTAssertEqual(receivedValue?.response.statusCode, response.statusCode)
    }
    
    
    func test_performRequest_succedsWithEmptyDataOnHTTPURLResponseWithNilData() {
        let response = anyHTTPURLResponse()
        let emptyData = emptyData()
        
        let receivedValue = resultValuesFor(data: emptyData, response: response, error: nil)
        
        XCTAssertEqual(receivedValue?.data, emptyData)
        XCTAssertEqual(receivedValue?.response.url, response.url)
        XCTAssertEqual(receivedValue?.response.statusCode, response.statusCode)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> URLSessionHTTPClient {
        let sut = URLSessionHTTPClient()
        
        trackForMemoryLeak(sut, file: file, line: line)
        
        return sut
    }
    
    
    private func resultErrorFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        
        URLProtocolStub.stub(data: data, response: response, error: error)
        
        var receivedError: Error?
        let exp = expectation(description: "Waiting for completion")
        
        makeSUT(file: file, line: line).perform(anyRequest()) { result in
            
            switch result {
            case let .failure(error):
                receivedError = error
               
            default: XCTFail("Expected to fail, got \(result) instead.", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
        
        return receivedError
    }
    
    
    func resultValuesFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> (data: Data, response: HTTPURLResponse)? {
        
        URLProtocolStub.stub(data: data, response: response, error: error)

        var receivedResult: (data: Data, response: HTTPURLResponse)?
        let exp = expectation(description: "Waiting for completion")
        
        makeSUT().perform(anyRequest()) { result in
            
            switch result {
            case let .success((receivedData, receivedResponse)):
                receivedResult = (receivedData, receivedResponse)
               
            default: XCTFail("Expected success, got \(result) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
        
        return receivedResult
    }
    
    // MARK: URLProtocol subclass
    
    private class URLProtocolStub: URLProtocol {
      
        private static var stub: Stub?
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        static func stub(data: Data? = nil, response: URLResponse? = nil, error: Error? = nil) {
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
