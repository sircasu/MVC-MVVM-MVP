//
//  UIControl+TestHelpers.swift
//  MVVMTests
//
//  Created by Matteo Casu on 08/01/26.
//

import UIKit

extension UIControl {
    func simulate(event: UIControl.Event) {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: event)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
