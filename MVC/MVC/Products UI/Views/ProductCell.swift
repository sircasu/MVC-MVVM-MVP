//
//  ProductCell.swift
//  MVC
//
//  Created by Matteo Casu on 22/12/25.
//

import UIKit

public final class ProductCell: UITableViewCell {
    
    public var title = UILabel()
    public var productDescription = UILabel()
    public var price = UILabel()
    public var productImageContainer = UIView()
    public var productImageView = UIImageView()
    
    private(set) public lazy var retryButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    
    var retryAction: (() -> Void)?

    
    @objc private func retryButtonTapped() {
        retryAction?()
    }
}
