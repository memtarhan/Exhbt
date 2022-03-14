//
//  Button.swift
//  Exhbt
//
//  Created by Shouvik Paul on 4/12/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import UIKit

class Button: UIButton {
    static let bigWidth: CGFloat = 270
    static let bigHeight: CGFloat = 45
    
    weak var shade: CALayer?

    init(title: String, fontSize: CGFloat = 16) {
        super.init(frame: .zero)
        
        setTitle(title, for: .normal)
        setTitleColor(.DarkGray(), for: .normal)
        titleLabel?.font = UIFont(name: FontWeight.bold.rawValue, size: fontSize)
        layer.cornerRadius = 4
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let shade = self.shade {
            shade.frame = bounds
            shade.cornerRadius = layer.cornerRadius
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let shade = createShade()
        layer.addSublayer(shade)
        self.shade = shade
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        shade?.removeFromSuperlayer()
        super.touchesEnded(touches, with: event)
    }
    
    private func createShade() -> CALayer {
        let shadeLayer = CALayer()
        shadeLayer.frame = bounds
        shadeLayer.opacity = 0.05
        shadeLayer.backgroundColor = UIColor.black.cgColor
        return shadeLayer
    }
}

class PrimaryButton: Button {
    override init(title: String, fontSize: CGFloat = 16) {
        super.init(title: title, fontSize: fontSize)
        
        setTitleColor(.white, for: .normal)
        backgroundColor = .EXRed()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ProfileButton: Button {
    override init(title: String, fontSize: CGFloat = 16) {
        super.init(title: title, fontSize: fontSize)
        
        setTitleColor(.EXRed(), for: .normal)
        backgroundColor = .white
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.EXRed().cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
