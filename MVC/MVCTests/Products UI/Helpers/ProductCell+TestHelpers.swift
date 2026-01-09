//
//  ProductCell+TestHelpers.swift
//  MVCTests
//
//  Created by Matteo Casu on 09/01/26.
//

import UIKit
import MVC

extension ProductCell {
    var titleText: String? { title.text }
    var descriptionText: String? { productDescription.text }
    var priceText: String? { price.text }
    
    
    var isShowingImageLoadingIndicator: Bool { productImageContainer.isShimmering }
    
    var renderedImage: Data? { productImageView.image?.pngData() }
    
    var isShowingRetryAction: Bool { !retryButton.isHidden }
    
    func simulateRetryAction() {
        retryButton.simulateTap()
    }
}
