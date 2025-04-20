//
//  EventStatusView.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 19/11/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import UIKit

class EventStatusView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var timeLeftLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    func setup() {
        contentView = loadFromNib(String(describing: EventStatusView.self))
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.frame = bounds
        addSubview(contentView)

        contentView.backgroundColor = .white
        backgroundColor = .clear

        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 12
        contentView.layer.borderWidth = 1.5
        contentView.layer.borderColor = UIColor.red.cgColor
//        contentView.layer.addGradienBorder(colors: [.red, .white], width: 3, cornerRadius: 12)
    }

    func update(withStatus status: EventStatusDisplayModel) {
        contentView.layer.borderColor = status.status.color.cgColor
        statusLabel.text = status.status.title
        statusLabel.textColor = status.status.color
        timeLeftLabel.text = status.timeLeft
    }
}
