//
//  ProductsViewModel.swift
//  MVVM
//
//  Created by Matteo Casu on 24/02/26.
//

import Foundation

public final class ProductsViewModel {
    static var title: String {
        return NSLocalizedString("PRODUCTS_VIEW_TITLE", tableName: "Products", bundle: Bundle(for: ProductsViewModel.self), comment: "Title for the product view")
    }
}
