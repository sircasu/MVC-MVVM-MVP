//
//  UITableView+Dequeueing.swift
//  MVP
//
//  Created by Matteo Casu on 13/02/26.
//

import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        let identifier = String(describing: T.self)
        return dequeueReusableCell(withIdentifier: identifier) as! T
    }
}
