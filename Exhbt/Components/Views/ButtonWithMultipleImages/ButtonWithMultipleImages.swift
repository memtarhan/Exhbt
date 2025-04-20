//
//  ButtonWithMultipleImages.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 14/10/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import UIKit

protocol ButtonWithMultipleImagesDelegate: AnyObject {
    func buttonWithMultipleImagesDidTap()
}

@IBDesignable
class ButtonWithMultipleImages: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet var containerView: UIView!

    @IBOutlet var leftImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var rightImageView: UIImageView!

    @IBInspectable var leftImage: UIImage? {
        didSet {
            leftImageView.image = leftImage
        }
    }

    @IBInspectable var title: String? {
        didSet {
            titleLabel.text = title
        }
    }

    @IBInspectable var rightImage: UIImage? {
        didSet {
            rightImageView.image = rightImage
        }
    }

    weak var delegate: ButtonWithMultipleImagesDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        contentView = loadFromNib(String(describing: ButtonWithMultipleImages.self))
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.frame = bounds
        addSubview(contentView)

        contentView.backgroundColor = .clear

        containerView.layer.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1).cgColor
        containerView.layer.cornerRadius = 12

        rightImageView.tintColor = .systemBlue
        leftImageView.tintColor = .systemBlue

        contentView.isUserInteractionEnabled = true
        contentView.gestureRecognizers?.forEach { contentView.removeGestureRecognizer($0) }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
        contentView.addGestureRecognizer(tapGesture)
    }

    @objc private func didTap(_ sender: UITapGestureRecognizer) {
        delegate?.buttonWithMultipleImagesDidTap()
    }
}
