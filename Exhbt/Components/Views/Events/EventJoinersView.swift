//
//  EventJoinersView.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 13/10/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import UIKit

class EventJoinersView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var imageViews: [UIImageView]!
    @IBOutlet var photosStackView: UIStackView!
    @IBOutlet var titleLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    func setup() {
        contentView = loadFromNib(String(describing: EventJoinersView.self))
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.frame = bounds
        addSubview(contentView)

        contentView.backgroundColor = .clear
        backgroundColor = .clear

        stackView.isHidden = true
    }

    func update(withModel model: EventJoinersDisplayModel) {
        imageViews.forEach { $0.isHidden = true }

        model.photos.enumerated().forEach { index, url in
            self.imageViews[index].loadImage(urlString: url)
            self.imageViews[index].isHidden = false
        }

        titleLabel.text = model.title

        stackView.isHidden = false
        photosStackView.isHidden = model.photos.isEmpty
    }
}
