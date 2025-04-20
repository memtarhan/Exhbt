//
//  BorderedButton.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 25/03/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import UIKit

@IBDesignable
class BorderedButton: UIButton {
    var config = UIButton.Configuration.plain()

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
        config.baseForegroundColor = .systemBlue
        config.background.strokeColor = .systemBlue
        config.background.strokeWidth = 1.5
        configuration = config
    }
}
