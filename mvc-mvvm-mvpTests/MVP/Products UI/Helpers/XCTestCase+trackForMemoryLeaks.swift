//
//  XCTestCase+trackForMemoryLeaks.swift
//  MVPTests
//
//  Created by Matteo Casu on 21/01/26.
//

import XCTest

extension XCTestCase {
    
    public func trackForMemoryLeak(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated, Potential memory leak.", file: file, line: line)
        }
    }
}

