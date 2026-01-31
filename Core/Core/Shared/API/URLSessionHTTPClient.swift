//
//  URLSessionHTTPClient.swift
//  Core
//
//  Created by Matteo Casu on 31/01/26.
//

import Foundation

final public class URLSessionHTTPClient: HTTPClient {
    
    let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    
    private struct UnexpectedValueRepresentation: Error {}
    
    
    public func perform(_ request: URLRequest, completion: @escaping (HTTPClient.Result) -> Void ) {
        
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
