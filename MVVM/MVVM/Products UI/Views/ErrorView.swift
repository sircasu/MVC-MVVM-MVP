//
//  ErrorView.swift
//  MVVM
//
//  Created by Matteo Casu on 15/03/26.
//

import UIKit


public class ErrorView: UIView {
    let messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemPink
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    public var message: String? {
        didSet { messageLabel.text = message }
    }
    
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    
    private func setupViews() {
        
        addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            messageLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
