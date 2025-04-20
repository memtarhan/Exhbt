//
//  VerticalCompetitorsView.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 18/11/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import UIKit

class VerticalCompetitorsView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var stackView: UIStackView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        contentView = loadFromNib(String(describing: VerticalCompetitorsView.self))
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.frame = bounds
        addSubview(contentView)

        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }

    func update(_ type: CompetitorStatusType) {
        titleLabel.text = type == .pending ? "PENDING" : "ACCEPTED"

        switch type {
        case .pending:
            titleLabel.text = "PENDING"

            let single = VerticalSingleCompetitorView(frame: CGRect(x: 0, y: 0, width: stackView.frame.width, height: stackView.frame.height))
            single.update(isMe: false)
            

            stackView.addArrangedSubview(single)
            
            single.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
            single.heightAnchor.constraint(equalToConstant: 64).isActive = true
            
        case .accepted:
            titleLabel.text = "ACCEPTED"

            let single = VerticalSingleCompetitorView(frame: CGRect(x: 0, y: 0, width: stackView.frame.width, height: stackView.frame.height))
            single.update(isMe: true)

            stackView.addArrangedSubview(single)
            
            single.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
            single.heightAnchor.constraint(equalToConstant: 64).isActive = true
            
        }
    }
}

enum CompetitorStatusType {
    case accepted
    case pending
}
