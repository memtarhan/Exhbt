//
//  GrayButton.swift
//  Exhbt
//
//  Created by Bekzod Rakhmatov on 10/05/23.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import UIKit

@IBDesignable
class GrayButton: UIButton {
    var config = UIButton.Configuration.gray()

    @IBInspectable var title: String? {
        didSet {
            config.title = title
            setup()
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
        config.background.backgroundColor = .systemGray4
        config.baseForegroundColor = .black
        configuration = config
    }
}
