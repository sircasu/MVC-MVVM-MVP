//
//  ProductsErrorViewModel.swift
//  Core
//
//  Created by Matteo Casu on 15/03/26.
//

import Foundation

public struct ProductsErrorViewModel {
    public let message: String?
    
    static var noError: ProductsErrorViewModel {
        ProductsErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> ProductsErrorViewModel {
        ProductsErrorViewModel(message: message)
    }
}
