//
//  VoteStyleViewer.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 04/05/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import UIKit

class VoteStyleViewer: BaseViewController, Nibbable {
    // MARK: - Outlets

    @IBOutlet var containerView: UIView!
    @IBOutlet var voteStackView: UIStackView!

    private let votes = VoteStyle.allCases

    var userService: ProfileServiceProtocol!

    weak var delegate: VoteStyleViewerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        containerView.layer.cornerRadius = FeedTableViewCell.cornerRadius
        containerView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]

        voteStackView.arrangedSubviews.forEach { subview in
            subview.isUserInteractionEnabled = true
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapVote(_:)))
            subview.addGestureRecognizer(tapGesture)
        }
    }

    @IBAction func didTap(_ sender: Any) {
        dismiss(animated: true)
    }

    @objc private func didTapVote(_ sender: UITapGestureRecognizer) {
        startLoading()

        if let tag = sender.view?.tag, let voteStyle = VoteStyle(rawValue: tag) {
            delegate?.voteStyleViewer(didSelectVoteStyle: voteStyle)
            stopLoading()
            dismiss(animated: true)
        } else {
            delegate?.voteStyleViewer(didFailWithError: VoteStyleViewerError.failedToCreate)
            stopLoading()
            dismiss(animated: true)
        }
    }
}

protocol VoteStyleViewerDelegate: AnyObject {
    func voteStyleViewer(didSelectVoteStyle style: VoteStyle)
    func voteStyleViewer(didFailWithError error: Error)
}

enum VoteStyleViewerError: Error {
    case failedToCreate
}
