//
//  ExhbtSettingsView.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 18/11/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import Combine
import UIKit

class ExhbtSettingsView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var collapseButton: UIButton!
    @IBOutlet var detailsView: UIView!

    @Published var didSelectCategory = CurrentValueSubject<Bool, Never>(false)
    @Published var selectedCategory = CurrentValueSubject<Category?, Never>(nil)

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

    private func setup() {
        contentView = loadFromNib(String(describing: ExhbtSettingsView.self))
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.frame = bounds
        addSubview(contentView)

        backgroundColor = .clear
        contentView.backgroundColor = .clear

        collapsed
            .receive(on: DispatchQueue.main)
            .sink { collapsed in
                self.detailsView.isHidden = !collapsed
                self.collapseButton.setImage(collapsed ? UIImage(named: "Exhbt-chevron-top") : UIImage(named: "Exhbt-chevron-bottom"), for: .normal)
            }
            .store(in: &cancellables)
    }
}
