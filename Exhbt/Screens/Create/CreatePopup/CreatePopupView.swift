//
//  CreatePopupView.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 24/09/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import UIKit

protocol CreatePopupViewDelegate: AnyObject {
    func createPopupWillCreateExhbt()
    func createPopupWillCreateEvent()
    func createPopupWillDismiss()
}

class CreatePopupView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet var blurView: UIVisualEffectView!
    @IBOutlet var buttonsContainerView: UIView!

    weak var delegate: CreatePopupViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    func setup() {
        contentView = loadFromNib(String(describing: CreatePopupView.self))
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.frame = bounds
        addSubview(contentView)

        contentView.backgroundColor = .clear
        backgroundColor = .clear

        blurView.alpha = 1.0
        blurView.backgroundColor = .clear

        buttonsContainerView.layer.cornerRadius = 12
//        buttonsContainerView.layer.borderColor = UIColor.systemGray4.cgColor
//        buttonsContainerView.layer.borderWidth = 0.3

        blurView.isUserInteractionEnabled = true
        blurView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismiss)))
    }

    @IBAction func didTapCreateExhbt(_ sender: Any) {
        delegate?.createPopupWillCreateExhbt()
    }

    @IBAction func didTapCreateEvent(_ sender: Any) {
        delegate?.createPopupWillCreateEvent()
    }

    @objc
    private func dismiss() {
        delegate?.createPopupWillDismiss()
    }
}
