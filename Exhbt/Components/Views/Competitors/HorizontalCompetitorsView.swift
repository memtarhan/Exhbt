//
//  HorizontalCompetitorsView.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 15/10/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import UIKit

protocol HorizontalCompetitorsDelegate: AnyObject {
    func horizontalCompetitorsDidViewInfo()
    func horizontalCompetitors(willViewUser user: Int)
}

@IBDesignable
class HorizontalCompetitorsView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet var containerView: UIView!

    @IBOutlet var competitorPhotoViews: [CompetitorPhotoView]!
    @IBOutlet var infoImageView: UIImageView!

    weak var delegate: HorizontalCompetitorsDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        contentView = loadFromNib(String(describing: HorizontalCompetitorsView.self))
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.frame = bounds
        addSubview(contentView)

        contentView.backgroundColor = .clear
        containerView.backgroundColor = .clear

        infoImageView.tintColor = .systemBlue
        infoImageView.isUserInteractionEnabled = true
        infoImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapInfo(_:))))

        // Setup competitor photo views with numbers
        let models = Array(0 ... 8).map {
            CompetitorPhotoDisplayModel(id: nil, image: nil, photoURL: nil, status: nil, index: $0)
        }

        zip(competitorPhotoViews, models).forEach { view, model in
            view.update(withModel: model)
            view.delegate = self
        }
    }

    func update(withModels models: [CompetitorPhotoDisplayModel]) {
        for index in 0 ..< models.count {
            competitorPhotoViews[index].update(withModel: models[index])
        }

        for index in (models.count) ..< competitorPhotoViews.count {
            competitorPhotoViews[index].update(withModel: CompetitorPhotoDisplayModel(id: nil, image: nil, photoURL: nil, status: nil, index: index))
        }
    }

    @objc private func didTapInfo(_ sender: UITapGestureRecognizer) {
        delegate?.horizontalCompetitorsDidViewInfo()
    }
}

// MARK: - CompetitorPhotoViewDelegate

extension HorizontalCompetitorsView: CompetitorPhotoViewDelegate {
    func competitorPhotoView(willViewUser user: Int) {
        debugLog(self, "\(#function) userId: \(user)")
        delegate?.horizontalCompetitors(willViewUser: user)
    }
}
