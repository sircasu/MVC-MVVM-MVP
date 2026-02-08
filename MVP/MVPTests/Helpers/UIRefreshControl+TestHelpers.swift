//
//  UIRefreshControl+TestHelpers.swift
//  MVPTests
//
//  Created by Matteo Casu on 08/01/26.
//

import UIKit

extension UIRefreshControl {
    func simulatePullToRefresh() {
        simulate(event: .valueChanged)
    }
}
