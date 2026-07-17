//
//  SceneDelegateTests.swift
//  mvc-mvvm-mvpTests
//
//  Created by Matteo Casu on 17/07/2026.
//

import XCTest
@testable import mvc_mvvm_mvp
import MVP

class SceneDelegateTests: XCTestCase {
    
    func test_sceneWillConnectToSession_configuresRootViewController() throws {
        
        let sut = SceneDelegate()
        let windowSpy = WindowSpy()
        
        sut.configureWindow(window: windowSpy)

        
        let root = windowSpy.rootViewController
        let tabController = try XCTUnwrap(root as? UITabBarController,
            "expected UITabBarController, got \(String(describing: root)) instead")

        let navController = try XCTUnwrap(tabController.viewControllers?.first as? UINavigationController,
            "expected UINavigationController, got \(String(describing: tabController.viewControllers?.first)) instead")

        XCTAssertTrue(navController.topViewController is ProductsViewController,
            "expected ProductsViewController, got \(String(describing: navController.topViewController)) instead")
        
    }
}


class WindowSpy: WindowProtocol {
    var rootViewController: UIViewController?
    var makeKeyAndVisibleCalled = false
    
    func makeKeyAndVisible() {
        makeKeyAndVisibleCalled = true
    }
}
