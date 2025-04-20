//
//  InfoTextBox.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 16/10/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import UIKit

@IBDesignable
class InfoTextBox: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet var containerView: UIView!

    @IBInspectable var background: UIColor = .systemGreen {
        didSet {
            containerView.backgroundColor = background

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
        contentView = loadFromNib(String(describing: InfoTextBox.self))
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.frame = bounds
        addSubview(contentView)

        contentView.backgroundColor = .clear
        containerView.layer.cornerRadius = 7.0
    }
}
