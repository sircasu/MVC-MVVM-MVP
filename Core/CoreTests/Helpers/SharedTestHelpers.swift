//
//  SharedTestHelpers.swift
//  CoreTests
//
//  Created by Matteo Casu on 31/01/26.
//

import Foundation


func anyURL() -> URL {
    URL(string: "https://any-url.com")!
}

func anyNSError() -> NSError {
    NSError(domain: "test", code: 0)
}
