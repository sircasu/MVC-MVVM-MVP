//
//  HTTPClientSpy.swift
//  CoreTests
//
//  Created by Matteo Casu on 02/02/26.
//

import Foundation
import Core

class HTTPClientSpy: HTTPClient {

    private struct Task: HTTPClientTask {
        let callback: () -> Void
        func cancel() {
            callback()
        }
    }
    
    var messages = [(request: URLRequest, completion: (HTTPClient.Result) -> Void)]()
    
    var requests: [URLRequest] {
        messages.map { $0.request }
    }
    
    var cancelledURLs = [URL]()
    
    func perform(_ request: URLRequest, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        messages.append((request, completion))
        return Task { [weak self] in
            self?.cancelledURLs.append(request.url!)
        }
    }
    
    func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0) {
        let response = HTTPURLResponse(url: messages[index].request.url!, statusCode: code, httpVersion: nil, headerFields: nil)!
        
        messages[index].completion(.success((data, response)))
    }
    
    func completeWithError(_ error: Error, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }

}
