//
//  ProductsLoader.swift
//  Core
//
//  Created by Matteo Casu on 21/12/25.
//

import Foundation

public protocol ProductsLoader {
    typealias Result = Swift.Result<[ProductItem], Error>
    func getProducts(completion: @escaping (Result) -> Void)
}
