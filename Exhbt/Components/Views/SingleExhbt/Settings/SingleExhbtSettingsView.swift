//
//  SingleExhbtSettingsView.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 04/04/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Combine
import UIKit

class SingleExhbtSettingsView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet var expandButton: UIButton!
    @IBOutlet var expandableView: UIView!

    @IBOutlet var categoryContainerView: UIView!

    private var cancellables: Set<AnyCancellable> = []

    @Published var shouldExpand = CurrentValueSubject<Bool, Never>(false)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    func setup() {
        contentView = loadFromNib(String(describing: SingleExhbtSettingsView.self))
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.frame = bounds
        addSubview(contentView)

        contentView.backgroundColor = .clear
        backgroundColor = .clear

        expandButton.addTarget(self, action: #selector(didTapExpandButton), for: .touchUpInside)

        categoryContainerView.layer.cornerRadius = 12

        shouldExpand
            .receive(on: DispatchQueue.main)
            .sink { expanded in
                self.expandableView.isHidden = !expanded
                let buttonImage = expanded ? UIImage(named: "Exhbt-chevron-top") : UIImage(named: "Exhbt-chevron-bottom")
                self.expandButton.setImage(buttonImage, for: .normal)
            }
            .store(in: &cancellables)
    }

    func update(withModel model: SingleExhbtSettingsModel) {
        expandButton.isEnabled = !model.isLocked
    }

    func disable() {
        expandButton.isEnabled = false
    }

    @objc
    private func didTapExpandButton() {
        shouldExpand.send(!shouldExpand.value)
    }
}
