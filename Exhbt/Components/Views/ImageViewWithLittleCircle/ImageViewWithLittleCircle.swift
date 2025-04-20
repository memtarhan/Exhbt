//
//  ImageViewWithLittleCircle.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 09/10/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import UIKit

@IBDesignable
class ImageViewWithLittleCircle: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet var imageView: UIImageView!

    @IBInspectable var image: UIImage? {
        didSet {
            imageView.image = image
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

    func setup() {
        contentView = loadFromNib(String(describing: ImageViewWithLittleCircle.self))
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.frame = bounds
        addSubview(contentView)

        imageView.layer.cornerRadius = imageView.frame.height / 2

        imageView.backgroundColor = .systemYellow
    }
}
