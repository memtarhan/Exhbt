//
//  VoteStatusView.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 18/05/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import UIKit

protocol VoteStatusDelegate: AnyObject {
    func voteStatus(didUpdateVoteStatus forCompetition: CompetitionDisplayModel)
}

class VoteStatusView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet var voteButton: UIButton!
    @IBOutlet var votesStackView: UIStackView!
    @IBOutlet var thumbImagesStackView: UIStackView!
    @IBOutlet var voteCountLabel: UILabel!

    private lazy var voteButtonConfig: UIButton.Configuration = {
        var config = UIButton.Configuration.filled()
        config.title = "Vote"
        config.cornerStyle = .capsule
        config.baseForegroundColor = .white
        config.baseBackgroundColor = .systemBlue
        config.titleAlignment = .center
        config.image = UIImage(named: "VoteThumb")
        config.imagePlacement = .leading
        config.imagePadding = 4.0
        config.buttonSize = .large
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)

        return config
    }()

    private lazy var removeVoteButtonConfig: UIButton.Configuration = {
        var config = UIButton.Configuration.filled()
        config.title = "Voted"
        config.cornerStyle = .capsule
        config.baseForegroundColor = .white
        config.baseBackgroundColor = .exhbtGray
        config.titleAlignment = .center
        config.image = UserSettings.shared.voteStyle?.thumbsImage
        config.imagePlacement = .leading
        config.imagePadding = 4.0
        config.buttonSize = .large
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)

        return config
    }()

    weak var delegate: VoteStatusDelegate?

    private var model: CompetitionDisplayModel?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    func setup() {
        contentView = loadFromNib(String(describing: VoteStatusView.self))
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.frame = bounds
        addSubview(contentView)

        backgroundColor = .clear

        votesStackView.isHidden = true
        voteButton.isHidden = true

        voteButton.addTarget(self, action: #selector(didTapVote), for: .touchUpInside)
    }

    func update(withModel model: CompetitionDisplayModel) {
        self.model = model
        
        thumbImagesStackView.arrangedSubviews.forEach { subview in
            self.thumbImagesStackView.removeArrangedSubview(subview)
        }

        voteButton.configuration = model.voted ? removeVoteButtonConfig : voteButtonConfig
        voteButton.isHidden = false

        model.voteStyles.forEach { style in
            thumbImagesStackView.addArrangedSubview(UIImageView(image: style.thumbsImage))
        }

        votesStackView.isHidden = model.votes.isEmpty
        voteCountLabel.text = "\(model.votesCount)" // TODO: Apply number formatter
    }

    @objc
    private func didTapVote() {
        guard let model else { return }
        delegate?.voteStatus(didUpdateVoteStatus: model)
    }
}
