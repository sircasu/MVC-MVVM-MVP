//
//  UIButton+TestHelpers.swift
//  MVCTests
//
//  Created by Matteo Casu on 06/01/26.
//

import UIKit

extension UIButton {
    
    func simulateTap() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
