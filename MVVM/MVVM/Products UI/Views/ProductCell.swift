//
//  ProductCell.swift
//  MVVM
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
    var onReuse: (() -> Void)?
    
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupViews()
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        
        onReuse?()
    }
    
    @objc private func retryButtonTapped() {
        retryAction?()
    }
    
    
    private func setupViews() {
        title.numberOfLines = 0
        productDescription.numberOfLines = 3

        productImageView.translatesAutoresizingMaskIntoConstraints = false
        productImageContainer.translatesAutoresizingMaskIntoConstraints = false
        retryButton.translatesAutoresizingMaskIntoConstraints = false
        productImageContainer.addSubview(productImageView)
        productImageContainer.addSubview(retryButton)

        let vStack = UIStackView(arrangedSubviews: [title, productDescription, price])
        vStack.axis = .vertical
        vStack.spacing = 8

        let externalHStack = UIStackView(arrangedSubviews: [productImageContainer, vStack])
        externalHStack.axis = .horizontal
        externalHStack.spacing = 8
        externalHStack.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(externalHStack)
        
        NSLayoutConstraint.activate([
            externalHStack.topAnchor.constraint(equalTo: contentView.topAnchor),
            externalHStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            externalHStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            externalHStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            productImageContainer.widthAnchor.constraint(equalToConstant: 100),
            productImageView.heightAnchor.constraint(equalToConstant: 100),
            productImageView.widthAnchor.constraint(equalToConstant: 100),

            productImageView.centerXAnchor.constraint(equalTo: productImageContainer.centerXAnchor),
            productImageView.centerYAnchor.constraint(equalTo: productImageContainer.centerYAnchor),

            retryButton.centerXAnchor.constraint(equalTo: productImageContainer.centerXAnchor),
            retryButton.centerYAnchor.constraint(equalTo: productImageContainer.centerYAnchor)
        ])
    }
}
