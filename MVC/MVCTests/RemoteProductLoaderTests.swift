//
//  RemoteProductLoaderTests.swift
//  MVCTests
//
//  Created by Matteo Casu on 17/01/26.
//

import XCTest
import Core

class RemoteProductLoader {
    
    let url: URL
    let loader: RemoteLoaderSpy
    
    init(url: URL, loader: RemoteLoaderSpy) {
        self.url = url
        self.loader = loader
    }
    
    func load() {
        loader.load()
    }
}


final class RemoteProductLoaderTests: XCTestCase {
    
    func test_init_doesNotAskForProducts() {
        let url = URL(string: "http://any-url")!
        let loader = RemoteLoaderSpy()
        let _ = RemoteProductLoader(url: url, loader: loader)
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "http://any-url")!
        let loader = RemoteLoaderSpy()
        let sut = RemoteProductLoader(url: url, loader: loader)
        
        sut.load()
        
        XCTAssertEqual(loader.loadCallCount, 1)
    }
}

class RemoteLoaderSpy {
    var loadCallCount = 0
    
    func load() {
        loadCallCount += 1
    }
}
