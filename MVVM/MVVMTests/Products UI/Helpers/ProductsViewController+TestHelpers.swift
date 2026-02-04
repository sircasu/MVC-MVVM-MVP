//
//  ProductsViewController+TestHelpers.swift
//  MVCTests
//
//  Created by Matteo Casu on 08/01/26.
//

import UIKit
import MVVM

extension ProductsViewController {
    
    func simulateAppearance() {
        if !isViewLoaded {
            loadViewIfNeeded()
            replaceRefreshControlWithFakeForiOS17Support()
        }
        
        beginAppearanceTransition(true, animated: false) // viewWillAppear
        endAppearanceTransition() // viewIsAppearing+viewDidAppear
    }
    
    
    func replaceRefreshControlWithFakeForiOS17Support() {
        let fake = FakeRefreshControl()
        
        refreshControl?.allTargets.forEach { target in
            refreshControl?.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach { action in
                fake.addTarget(target, action: Selector(action), for: .valueChanged)
            }
        }
        
        refreshControl = fake
        refreshController?.view = fake
    }
    
    
    func simulateUserInitiatedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    
    var isShowingLoadingIndicator: Bool { refreshControl?.isRefreshing == true }
    
    var productSection: Int { 0 }
    var numberOfRenderedProductViews: Int {
        tableView.numberOfRows(inSection: productSection)
    }
    
    func productView(at row: Int) -> UITableViewCell? {
        let ds = tableView.dataSource
        let indexPath = IndexPath(row: row, section: productSection)
        return ds?.tableView(tableView, cellForRowAt: indexPath)
    }
    
    
    //
    @discardableResult
    func simulateProductImageBeginVisible(at index: Int) -> ProductCell? {
        let cell = productView(at: index) as? ProductCell
        return cell
    }
    
    @discardableResult
    func simulateProductImageNotVisible(at row: Int) -> ProductCell? {
        let view = simulateProductImageBeginVisible(at: row)
        
        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: productSection)
        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: index)
        
        return view
    }
    
    func simulateProductImageNearVisible(at row: Int) {
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: productSection)
        ds?.tableView(tableView, prefetchRowsAt: [index])
    }
    
    func simulateProductImageNotNearVisibleAnymore(at row: Int) {
        simulateProductImageNearVisible(at: row)
        
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: productSection)
        ds?.tableView?(tableView, cancelPrefetchingForRowsAt: [index])
    }
    
    @discardableResult
    func simulateProductBecomingVisibleAgain(at row: Int) -> ProductCell? {
        let view = simulateProductImageNotVisible(at: row)
        
        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: productSection)
        delegate?.tableView?(tableView, willDisplay: view!, forRowAt: index)
        
        return view
    }
}


private class FakeRefreshControl: UIRefreshControl {
    
    private var _isRefreshing = false
    
    
    override var isRefreshing: Bool { _isRefreshing }
    
    
    override func beginRefreshing() {
        _isRefreshing = true
    }
    
    override func endRefreshing() {
        _isRefreshing = false
    }
}
