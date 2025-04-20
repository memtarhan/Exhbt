//
//  NotificationPhotosView.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 17/09/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import UIKit

class NotificationPhotosView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet var singleImageView: UIImageView!
    @IBOutlet var doubleImagesView: UIView!
    @IBOutlet var doubleImageViews: [UIImageView]!

    var id: Int?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    func setup() {
        contentView = loadFromNib(String(describing: NotificationPhotosView.self))
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.frame = bounds
        addSubview(contentView)
    }

    func configure(withImages images: [String], isCircle: Bool) {
        update(images)

        singleImageView.layer.cornerRadius = isCircle ? 24 : 5
        doubleImageViews.forEach { imageView in
            imageView.layer.cornerRadius = isCircle ? 12 : 2.5
        }
    }

    private func update(_ images: [String]) {
        if images.count == 1 {
            doubleImagesView.isHidden = true
            singleImageView.isHidden = false

            singleImageView.loadImage(urlString: images[0])

        } else if images.count == 2 {
            doubleImagesView.isHidden = false
            singleImageView.isHidden = true

            for index in 0 ..< images.count {
                doubleImageViews[index].loadImage(urlString: images[0])
            }
        }
    }
}
