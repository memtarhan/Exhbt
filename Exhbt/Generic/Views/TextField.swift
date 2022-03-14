//
//  TextField.swift
//  Exhbt
//
//  Created by Shouvik Paul on 5/3/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import UIKit

class TextField: UITextField {
    
    init(
        text: String? = nil,
        placeholder: String? = nil,
        fontSize: CGFloat = 20
    ) {
        super.init(frame: .zero)
        
        self.textColor = .DarkGray()
        self.text = text
        self.placeholder = placeholder
        self.font = UIFont(name: "Helvetica Neue", size: fontSize)
        self.textAlignment = .center
        addBottomBorder()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addBottomBorder() {
        let bottomBorder = UIView()
        bottomBorder.backgroundColor = .DarkGray()
        addSubview(bottomBorder)
        bottomBorder.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    let padding = UIEdgeInsets(top: 0, left: 8, bottom: 12, right: 8)
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}
