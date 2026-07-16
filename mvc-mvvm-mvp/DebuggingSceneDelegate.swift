//
//  DebuggingSceneDelegate.swift
//  mvc-mvvm-mvp
//
//  Created by Matteo Casu on 16/07/2026.
//
#if DEBUG
import UIKit
import Core
import MVP

class DebuggingSceneDelegate: SceneDelegate {
    override func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let _ = (scene as? UIWindowScene) else { return }

        // Any Debugging/Test configuration
        
        super.scene(scene, willConnectTo: session, options: connectionOptions)
    }


    override func makeRemoteClient() -> HTTPClient {
        if let connectivity = UserDefaults.standard.string(forKey: "connectivity") {
            return DebuggingHTTPClient(connectivity: connectivity)
        }
    
        return super.makeRemoteClient()
    }
}

private class DebuggingHTTPClient: HTTPClient {
    
    private class Task: HTTPClientTask {
        func cancel() {}
    }
    
    private let connectivity: String
    
    init(connectivity: String) {
        self.connectivity = connectivity
    }
    
    func perform(_ request: URLRequest, completion: @escaping (HTTPClient.Result) -> Void) ->  HTTPClientTask {
        
        switch connectivity {
        case "online":
            completion(.success(makeSuccessfulResponse(for: request.url!)))
        default:
            completion(.failure(NSError(domain: "test", code: 0)))
        }
      
        return Task()
    }
    
    
    private func makeSuccessfulResponse(for url: URL) -> (Data, HTTPURLResponse) {
        let response = HTTPURLResponse(url: .init(string: "https://www.anyurl.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (makeData(for: url), response)
    }
    
    
    private func makeData(for url: URL) -> Data {
        switch url.absoluteString {
        case "https://image.com":
             return makeImageData()
            
        default:
            return makeProductsData()
        }
    }
    
    private func makeImageData() -> Data {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(UIColor.red.cgColor)
        context.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!.pngData()!
    }
    
    private func makeProductsData() -> Data {
        return try! JSONSerialization.data(withJSONObject: [
            ["id": 1,
             "title": "Product 1",
             "price": 35.00,
             "description": "a description",
             "category": "a category",
             "image": "https://image.com"
            ],
            ["id": 2,
             "title": "Product 2",
             "price": 14.99,
             "description": "a description 2",
             "category": "a category 2",
             "image": "https://image.com"
            ]
        ])
    }
}


#endif
