//
//  FilledButton.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 25/03/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import UIKit

@IBDesignable
class FilledButton: UIButton {
    var config = UIButton.Configuration.filled()

    @IBInspectable var title: String? {
        didSet {
            config.title = title
            setup()
        }
    }

    @IBInspectable var color: UIColor? = .systemBlue {
        didSet {
            setup()
        }
    }

    @IBInspectable var textColor: UIColor? = .white {
        didSet {
            setup()
        }
    }

    override var isEnabled: Bool {
        didSet {
            if isEnabled {
                enable()

            } else {
                disable()
            }
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
        config.background.backgroundColor = color
        config.baseForegroundColor = textColor
        config.cornerStyle = .small
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 24, bottom: 8, trailing: 24)
        configuration = config
    }

    private func enable() {
        config.background.backgroundColor = color
        config.baseForegroundColor = textColor
        config.cornerStyle = .small
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 24, bottom: 8, trailing: 24)
        configuration = config
    }

    private func disable() {
        config.background.backgroundColor = .systemGray4
        config.baseForegroundColor = .white
        config.cornerStyle = .small
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 24, bottom: 8, trailing: 24)
        configuration = config
    }
}

@IBDesignable
class GrayCapsuleButton: UIButton {
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
        config.cornerStyle = .capsule
        config.baseForegroundColor = .black
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 24, bottom: 8, trailing: 24)

        configuration = config
    }
}
