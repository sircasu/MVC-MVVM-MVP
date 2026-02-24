//
//  ProductViewControllerTests+Localized.swift
//  MVCTests
//
//  Created by Matteo Casu on 24/02/26.
//

import Foundation
import XCTest
import MVC

extension ProductsViewControllerTests {
    func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let table = "Products"
        let bundle = Bundle(for: ProductsViewController.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if key == value {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
    }
}
