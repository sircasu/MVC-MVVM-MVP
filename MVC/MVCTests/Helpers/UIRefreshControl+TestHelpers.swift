//
//  UIRefreshControl+TestHelpers.swift
//  MVCTests
//
//  Created by Matteo Casu on 08/01/26.
//

import UIKit

extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
