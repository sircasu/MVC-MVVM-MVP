//
//  ProductsAcceptanceTests.swift
//  mvc-mvvm-mvpTests
//
//  Created by Matteo Casu on 20/07/2026.
//

import XCTest
@testable import mvc_mvvm_mvp
import Core
import MVP

class ProductsAcceptanceTests: XCTestCase {
    
    func test_onLaunch_displaysRemoteProductsWhenCustomerHasConnectivity() {

        let sut = launch(httpClient: .online(response))
        sut.simulateAppearance()
        
        XCTAssertEqual(sut.numberOfRenderedProductViews, 2)
        XCTAssertEqual(sut.renderedProductImageData(at: 0), makeImageData())
        XCTAssertEqual(sut.renderedProductImageData(at: 1), makeImageData())
    }
    
    
    func test_onLaunch_displaysEmpryProductsWhenUserHasNoConnectivity() {

    }
    
    
    // MARK: - Helpers
    
    private func launch(
        httpClient: HTTPClientStub = .offline,
    ) -> ProductsViewController {
        let sut = SceneDelegate(httpClient: httpClient)
        let windowSpy = WindowSpy()
        
        sut.configureWindow(window: windowSpy)
        
        let root = windowSpy.rootViewController
        let tabController = root as! UITabBarController
        let nav = tabController.viewControllers?.first as? UINavigationController
        let productsVC = nav?.topViewController as! ProductsViewController
        
        return productsVC
    }
    
    
    func response(for request: URLRequest) -> (Data, HTTPURLResponse) {
        makeSuccessfulResponse(for: request.url!)
    }
    
    
    private func makeSuccessfulResponse(for url: URL) -> (Data, HTTPURLResponse) {
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
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
        return  UIImage.make(withColor: .red).pngData()!
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


private class HTTPClientStub: HTTPClient {
    
    private class Task: HTTPClientTask {
        func cancel() {}
    }
    
    private let stub: (URLRequest) -> HTTPClient.Result
    
    public init(stub: @escaping (URLRequest) -> HTTPClient.Result) {
        self.stub = stub
    }
    
    func perform(_ request: URLRequest, completion: @escaping (HTTPClient.Result) -> Void) ->  HTTPClientTask {
        
        completion(stub(request))
        return Task()
    }
    
    
    static var offline: HTTPClientStub {
        HTTPClientStub (stub: { _ in .failure(NSError(domain: "test", code: 0)) } )
    }
    
    static func online(_ stub: @escaping(URLRequest) -> (Data, HTTPURLResponse)) -> HTTPClientStub {
        HTTPClientStub (stub: { .success(stub($0)) } )
    }
}
