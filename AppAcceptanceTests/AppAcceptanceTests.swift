//
//  AppAcceptanceTests.swift
//  AppAcceptanceTests
//
//  Created by Matteo Casu on 14/07/2026.
//

import XCTest
import MVP
final class AppAcceptanceTests: XCTestCase {

    func test_onLaunch_displaysRemoteProductsWhenCustomerHasConnectivity() {
        let app = XCUIApplication()
        
        app.launch()
        
        let productCells = app.cells.matching(identifier: String(describing: ProductCell.self))
        XCTAssertTrue(productCells.count > 0)
        
        let firstImage = app.images.matching(identifier: "product-image-view").firstMatch
        XCTAssert(firstImage.exists)
    }
}
