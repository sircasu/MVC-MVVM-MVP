//
//  UIButton+TestHelpers.swift
//  MVVMTests
//
//  Created by Matteo Casu on 06/01/26.
//

import UIKit

extension UIButton {
    
    func simulateTap() {
        simulate(event: .touchUpInside)
    }
}
