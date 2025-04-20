//
//  CompetitorPhotoView.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 26/03/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Kingfisher
import UIKit

protocol CompetitorPhotoViewDelegate: AnyObject {
    func competitorPhotoView(willViewUser user: Int)
}

class CompetitorPhotoView: UIView {
    @IBOutlet var contentView: UIView!

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var statusImageView: UIImageView!

    var competitorId: Int?

    weak var delegate: CompetitorPhotoViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        contentView = loadFromNib(String(describing: CompetitorPhotoView.self))
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.frame = bounds
        addSubview(contentView)

        backgroundColor = .clear
        contentView.backgroundColor = .clear

        imageView.image = UIImage(named: "BeautyCategory")
        imageView.layer.cornerRadius = (frame.height - 2) / 2

        contentView.isUserInteractionEnabled = true
        contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap(_:))))
    }

    func update(withModel model: CompetitorPhotoDisplayModel) {
        competitorId = model.id

        if let status = model.status {
            if let image = model.image {
                imageView.image = image

            } else if let url = model.photoURL {
                imageView.loadImage(urlString: url)

            } else {
                imageView.image = UIImage(systemName: "person")
            }

            update(withStatus: status)

        } else if let index = model.index {
            imageView.image = UIImage(systemName: "\(index + 1).circle.fill")
            statusImageView.isHidden = true
            imageView.layer.borderWidth = 0.0

        } else {
            imageView.image = UIImage(systemName: "questionmark.circle.fill")
            statusImageView.isHidden = true
            imageView.layer.borderWidth = 0.0
        }
    }

    func update(withStatus status: CompetitorAcceptanceStatus) {
        imageView.layer.borderColor = status.color.cgColor
        imageView.layer.borderWidth = 1.0
        statusImageView.image = status.image
        statusImageView.tintColor = status.color
    }

    @objc
    private func didTap(_ sender: UIGestureRecognizer) {
        guard let competitorId else { return }
        debugLog(self, "didTap userId: \(competitorId)")
        delegate?.competitorPhotoView(willViewUser: competitorId)
    }
}

struct CompetitorPhotoDisplayModel {
    let id: Int?
    let image: UIImage?
    let photoURL: String?
    let status: CompetitorAcceptanceStatus?
    let index: Int?
}

enum CompetitorAcceptanceStatus {
    case accepted
    case pending

    var color: UIColor {
        switch self {
        case .accepted:
            return .systemBlue
        case .pending:
            return .black
        }
    }

    var image: UIImage? {
        switch self {
        case .accepted:
            return UIImage(systemName: "checkmark.circle.fill")
        case .pending:
            return UIImage(systemName: "questionmark.circle.fill")
        }
    }
}
