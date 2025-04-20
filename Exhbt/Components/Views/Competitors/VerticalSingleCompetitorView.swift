//
//  VerticalSingleCompetitorView.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 18/11/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import UIKit

class VerticalSingleCompetitorView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet var imageView: CircleImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var editButton: UIButton!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        contentView = loadFromNib(String(describing: VerticalSingleCompetitorView.self))
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.frame = bounds
        addSubview(contentView)

        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }

    func update(isMe: Bool) {
        subtitleLabel.isHidden = isMe
        editButton.isHidden = isMe
    }
}
