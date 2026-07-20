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
        app.launchArguments = ["-connectivity", "online"]
        app.launch()
        
        let productCells = app.cells.matching(identifier: String(describing: ProductCell.self))
        XCTAssertEqual(productCells.count, 2)
        
        let firstImage = app.images.matching(identifier: "product-image-view").firstMatch
        XCTAssert(firstImage.exists)
    }
    
    
    func test_onLaunch_displaysEmptyProductsWhenUserHasNoConnectivity() {
        let app = XCUIApplication()
        app.launchArguments = ["-connectivity", "offline"]
        app.launch()
        
        let productCells = app.cells.matching(identifier: String(describing: ProductCell.self))
        XCTAssertEqual(productCells.count, 0)
    }
}
