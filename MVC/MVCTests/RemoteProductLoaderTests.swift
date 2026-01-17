//
//  RemoteProductLoaderTests.swift
//  MVCTests
//
//  Created by Matteo Casu on 17/01/26.
//

import XCTest
import Core

class RemoteProductLoader {
    
    let loader: RemoteLoaderSpy
    
    init(loader: RemoteLoaderSpy) {
        self.loader = loader
    }
}


final class RemoteProductLoaderTests: XCTestCase {
    
    func test_init_doesNotAskForProducts() {
        
        let loader = RemoteLoaderSpy()
        let _ = RemoteProductLoader(loader: loader)
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
}

class RemoteLoaderSpy {
    var loadCallCount = 0
}
