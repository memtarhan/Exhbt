//
//  ExhbtCompetitorsView.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 18/11/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import Combine
import UIKit

protocol ExhbtCompetitorsDelegate: AnyObject {
    func exhbtCompetitorsDidViewInfo()
    func exhbtCompetitorsWillAddCompetitors()
    func exhbtCompetitors(willViewUser user: Int)
}

class ExhbtCompetitorsView: UIView {
    @IBOutlet var contentView: UIView!

    @IBOutlet var horizontalCompetitorsContainerView: UIView!
    @IBOutlet var horizontalCompetitorsView: HorizontalCompetitorsView!
    @IBOutlet var verticalCompetitorsStackView: UIStackView!
    @IBOutlet var acceptedView: VerticalCompetitorsView!
    @IBOutlet var pendingView: VerticalCompetitorsView!

    @IBOutlet var collapseButton: UIButton!

    @Published var collapsed = CurrentValueSubject<Bool, Never>(false)

    private var cancellables: Set<AnyCancellable> = []

    weak var delegate: ExhbtCompetitorsDelegate?

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

    @IBAction func didTapInvite(_ sender: Any) {
        delegate?.exhbtCompetitorsWillAddCompetitors()
    }

    private func setup() {
        contentView = loadFromNib(String(describing: ExhbtCompetitorsView.self))
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.frame = bounds
        addSubview(contentView)

        backgroundColor = .clear
        contentView.backgroundColor = .clear

        horizontalCompetitorsView.delegate = self

        collapsed
            .receive(on: DispatchQueue.main)
            .sink { collapsed in
                self.horizontalCompetitorsContainerView.isHidden = collapsed
                self.verticalCompetitorsStackView.isHidden = !collapsed
                self.collapseButton.setImage(collapsed ? UIImage(named: "Exhbt-chevron-top") : UIImage(named: "Exhbt-chevron-bottom"), for: .normal)
            }
            .store(in: &cancellables)
    }

    func update() {
        acceptedView.update(.accepted)
        pendingView.update(.pending)

        layoutSubviews()
    }
}

extension ExhbtCompetitorsView: HorizontalCompetitorsDelegate {
    func horizontalCompetitorsDidViewInfo() {
        delegate?.exhbtCompetitorsDidViewInfo()
    }

    func horizontalCompetitors(willViewUser user: Int) {
        debugLog(self, "\(#function) userId: \(user)")
        delegate?.exhbtCompetitors(willViewUser: user)
    }
}
