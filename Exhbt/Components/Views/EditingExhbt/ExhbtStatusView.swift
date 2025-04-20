//
//  ExhbtStatusView.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 18/11/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import Combine
import UIKit

class ExhbtStatusView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var timeLeftLabel: UILabel!
    @IBOutlet var animationView: Spinner!
    @IBOutlet var detailsStackView: UIStackView!
    @IBOutlet var countDetailsView: UIView!
    @IBOutlet var countDetailsLabel: UILabel!
    @IBOutlet var liveStatusView: UIView!
    @IBOutlet var liveStatusLabel: UILabel!
    @IBOutlet var finishedStatusView: UIView!
    @IBOutlet var finishedStatusLabel: UILabel!

    @IBOutlet var collapseButton: UIButton!
    @Published var collapsed = CurrentValueSubject<Bool, Never>(false)

    private var cancellables: Set<AnyCancellable> = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    @IBAction func didTapCollapse(_ sender: Any) {
        collapsed.send(!collapsed.value)
    }

    func update(withModel model: ExhbtStatusDisplayModel) {
        titleLabel.attributedText = model.title
        timeLeftLabel.text = model.timeLeft
        countDetailsLabel.text = model.countDetails

        switch model.status {
        case .submissions, .archived:
            break
        case .live:
            liveStatusView.isHidden = true
            countDetailsView.isHidden = true
        case .finished:
            liveStatusView.isHidden = true
            finishedStatusView.isHidden = true
            countDetailsView.isHidden = true
        }
    }

    private func setup() {
        contentView = loadFromNib(String(describing: ExhbtStatusView.self))
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.frame = bounds
        addSubview(contentView)

        backgroundColor = .clear
        contentView.backgroundColor = .clear

        playLiveAnimation()

        collapsed
            .receive(on: DispatchQueue.main)
            .sink { collapsed in
                self.detailsStackView.isHidden = !collapsed
                self.collapseButton.setImage(collapsed ? UIImage(named: "Exhbt-chevron-top") : UIImage(named: "Exhbt-chevron-bottom"), for: .normal)
            }
            .store(in: &cancellables)
    }

    private func playLiveAnimation() {
        animationView.isHidden = false
        animationView.startRefreshing()
    }

    private func stopLiveAnimation() {
        animationView.isHidden = true
        animationView.stopRefreshing()
    }
}

struct ExhbtStatusDisplayModel {
    let title: NSAttributedString
    let timeLeft: String
    let countDetails: String
    let status: ExhbtStatus
}
