//
//  AppAcceptanceTests.swift
//  AppAcceptanceTests
//
//  Created by Matteo Casu on 14/07/2026.
//

import XCTest

final class AppAcceptanceTests: XCTestCase {

    func test_onLaunch_displaysRemoteProductsWhenCustomerHasConnectivity() {
        let app = XCUIApplication()
        
        app.launch()
        
        XCTAssertTrue(app.cells.count > 0)
    }
}
