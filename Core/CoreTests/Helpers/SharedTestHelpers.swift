//
//  SharedTestHelpers.swift
//  CoreTests
//
//  Created by Matteo Casu on 31/01/26.
//

import Foundation
import Core

func anyURL() -> URL {
    URL(string: "https://any-url.com")!
}

func anyNSError() -> NSError {
    NSError(domain: "test", code: 0)
}

func anyRequest() -> URLRequest {
    URLRequest(url: anyURL())
}

func anyURLResponse() -> URLResponse {
    URLResponse()
}

func anyHTTPURLResponse() -> HTTPURLResponse {
    HTTPURLResponse()
}

func emptyData() -> Data {
    Data()
}

func anyData() -> Data {
    Data("any data".utf8)
}

func makeItem(id: Int = UUID().hashValue, title: String = "a product", price: Double = 3.33, description: String = "a description", category: String = "a category", image: URL = URL(string: "https://any-image-url.com")!) -> (model: ProductItem, json: [String: Any]) {
    
    let model = ProductItem(id: id, title: title, price: price, description: description, category: category, image: image)
    
    let json = [
        "id": model.id,
        "title": model.title,
        "price": model.price,
        "description": model.description,
        "category": model.category,
        "image": model.image.absoluteString
    ] as [String : Any]
    
    return (model, json)
}
