//
//  SingleExhbtStatusView.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 04/04/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Combine
import UIKit

class SingleExhbtStatusView: UIView {
    @IBOutlet var contentView: UIView!

    @IBOutlet var stackView: UIStackView!
    @IBOutlet var infoView: UIStackView!
    @IBOutlet var spinnerView: Spinner!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var expandButton: UIButton!
    @IBOutlet var remainCountView: UIView!
    @IBOutlet var remainCountLabel: UILabel!
    @IBOutlet var detailsView: UIStackView!
    @IBOutlet var lineView: UIView!
    @IBOutlet var bottomStatusView: UIStackView!
    @IBOutlet var liveStatusView: UIStackView!
    @IBOutlet var finishedStatusView: UIStackView!

    var exhbtId: Int?

    private lazy var gradient: CAGradientLayer = {
        GradientLayers.exhbtStatusWhiteCover
    }()

    private var cancellables: Set<AnyCancellable> = []

    @Published var shouldExpand = CurrentValueSubject<Bool, Never>(false)

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
        contentView = loadFromNib(String(describing: SingleExhbtStatusView.self))
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.frame = bounds
        addSubview(contentView)

        contentView.backgroundColor = .clear
        backgroundColor = .clear

        spinnerView.startRefreshing()

//        detailsView.layer.addSublayer(gradient)

        expandButton.addTarget(self, action: #selector(didTapExpandButton), for: .touchUpInside)

        shouldExpand
            .receive(on: DispatchQueue.main)
            .sink { expanded in
                self.lineView.isHidden = !expanded
                let buttonImage = expanded ? UIImage(named: "Exhbt-chevron-top") : UIImage(named: "Exhbt-chevron-bottom")
                self.expandButton.setImage(buttonImage, for: .normal)
                self.detailsView.isHidden = !expanded

//                if expanded {
//                    self.gradient.frame = CGRect(x: 0, y: 0, width: self.detailsView.bounds.width, height: 64) // self.detailsView.bounds
//                }
            }
            .store(in: &cancellables)
    }

    func update(withModel model: SingleExhbtStatusModel) {
        exhbtId = model.id
        status = model.status

        expandButton.isEnabled = status != .finished

        remainCountLabel.text = model.remainingDescription
        updateStatusView(model)
    }

    func update(timeLeft: String) {
        guard let status,
              status == .finished else { return }
        statusLabel.attributedText = status.getStatusString(withTimeLeft: timeLeft)
    }

    private func updateStatusView(_ model: SingleExhbtStatusModel) {
        spinnerView.isHidden = model.status == .finished
        spinnerView.color = model.status.animationColor
        statusLabel.attributedText = model.status.getStatusString(withTimeLeft: model.timeLeft)
        remainCountView.isHidden = model.status == .finished || model.status == .live

        if model.status == .finished {
            bottomStatusView.isHidden = true

        } else if model.status == .live {
            liveStatusView.isHidden = true
        }
    }

    @objc
    private func didTapExpandButton() {
        shouldExpand.send(!shouldExpand.value)
    }
}
