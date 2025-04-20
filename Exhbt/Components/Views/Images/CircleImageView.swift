//
//  CircleImageView.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 15/10/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import UIKit

@IBDesignable
class CircleImageView: UIImageView {
    @IBInspectable
    var borderColor: UIColor = .clear {
        didSet {
            layer.borderColor = borderColor.cgColor
            layer.borderWidth = 2.0
        }
    }

    @IBInspectable
    var cornerRadius: CGFloat = 0.0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        layer.cornerRadius = frame.height / 2
        contentMode = .scaleAspectFill
    }
}
