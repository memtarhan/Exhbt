//
//  SingleExhbtPreviewView.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 04/04/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import UIKit

class ExhbtPreviewView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet var photosView: HorizontalPhotosView!
    @IBOutlet var statusView: UIView!
    @IBOutlet var spinnerView: Spinner!
    @IBOutlet var statusLeftLabel: UILabel!
    @IBOutlet var statusMiddleImageView: UIImageView!
    @IBOutlet var statusRightLabel: UILabel!
    @IBOutlet var editIconImageView: UIImageView!
    @IBOutlet var descriptionLabel: UILabel!

    var exhbtId: Int?
    private var timer: Timer?
    private var status: ExhbtStatus?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    func setup() {
        contentView = loadFromNib(String(describing: ExhbtPreviewView.self))
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.frame = bounds
        addSubview(contentView)

        contentView.backgroundColor = .clear
        backgroundColor = .clear

        contentView.layer.cornerRadius = FeedTableViewCell.cornerRadius
        contentView.layer.borderWidth = 0.0
        contentView.layer.borderColor = UIColor.systemBlue.cgColor

        photosView.makeRounded()
        statusView.makeCircle()
        statusView.layer.borderWidth = 1
        statusView.layer.borderColor = UIColor.white.cgColor
        spinnerView.color = .systemRed
        spinnerView.startRefreshing()

        editIconImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapEdit)))
        editIconImageView.isHidden = true
        editIconImageView.isUserInteractionEnabled = false
        updateStatusView(.live)
    }

    func update(withModel model: ExhbtPreviewDisplayModel, alreadyInEditMode: Bool) {
        exhbtId = model.id
        status = model.status

        updateStatusView(model.status)

        /// - Loading images
        photosView.id = model.id
        photosView.update(models: model.horizontalModels)

        if model.status == .live || model.status == .submissions {
            statusRightLabel.text = model.expirationDate.timeLeft
        }

        if model.status == .finished || model.status == .archived {
            editIconImageView.isHidden = true

        } else {
            editIconImageView.isHidden = !alreadyInEditMode
        }

        contentView.layer.borderWidth = model.isOwn ? 2.0 : 0.0

        descriptionLabel.attributedText = model.description.asHashtagText
    }

    func setupTimerLabel(_ expirationDate: Date) {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
            self?.statusRightLabel.text = expirationDate.timeLeft
        })
    }

    private func updateStatusView(_ status: ExhbtStatus) {
        statusView.backgroundColor = status.statusBackgroundColor
        statusLeftLabel.textColor = status.statusLabelColor
        statusLeftLabel.text = status.title
        statusLeftLabel.isHidden = status.shouldHideStatusLabel
        statusRightLabel.textColor = status.timeLeftColor
        spinnerView.isHidden = status.shoulHideAnimation
        statusMiddleImageView.tintColor = status.middleImageTintColor
        statusMiddleImageView.image = status.middleImage

        if status == .archived {
            statusRightLabel.isHidden = true
            statusMiddleImageView.isHidden = true
        }

        if status == .finished {
            statusRightLabel.text = status.title.capitalized
            statusRightLabel.isHidden = false
        }
    }

    @objc
    private func didTapEdit() {
        debugLog(self, #function)
    }
}
