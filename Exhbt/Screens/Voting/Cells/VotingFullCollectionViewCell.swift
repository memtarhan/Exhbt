//
//  VotingFullCollectionViewCell.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 17/05/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import UIKit
import SwiftUI

protocol VotingCellProtocol {
    func update(withModel model: CompetitionDisplayModel)
}

class VotingFullCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "VotingFullCollectionViewCell"

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var voteStatusView: VoteStatusView!

    weak var delegate: VotingDelegate?

    private var model: CompetitionDisplayModel?

    override func awakeFromNib() {
        super.awakeFromNib()

        voteStatusView.delegate = self
    }
    
    private func addVideoPlayer(_ url: String) {
        guard let videoURL = URL(string: url) else { return }
        
        let videoView = SimpleVideoContainerView(url: videoURL)

        let config = UIHostingConfiguration {
            videoView
        }
        
        let subview = config.makeContentView()
        subview.translatesAutoresizingMaskIntoConstraints = false

        imageView.addSubview(subview)

        NSLayoutConstraint.activate([
            subview.topAnchor.constraint(equalTo: imageView.topAnchor),
            subview.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            subview.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            subview.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
        ])
    }
}

// MARK: - VotingCellProtocol

extension VotingFullCollectionViewCell: VotingCellProtocol {
    func update(withModel model: CompetitionDisplayModel) {
        self.model = model

        voteStatusView.update(withModel: model)

        if let video = model.content.videoURL {
            addVideoPlayer(video)
        } else {
            imageView.loadImage(urlString: model.content.photoURL)
        }
    }
}

extension VotingFullCollectionViewCell: VoteStatusDelegate {
    func voteStatus(didUpdateVoteStatus forCompetition: CompetitionDisplayModel) {
        guard let model else { return }
        delegate?.voting(didUpdateVoteStatus: model)
    }
}
