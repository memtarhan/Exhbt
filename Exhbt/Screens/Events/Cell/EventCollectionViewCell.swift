//
//  EventCollectionViewCell.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 09/10/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import SwiftUI
import UIKit

protocol EventCollectionViewCellDelegate: AnyObject {
    func eventCollectionViewCell(didUpdateJoinStatusOfEvent event: EventDisplayModel)
}

class EventCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "EventCollectionViewCell"

    @IBOutlet var containerView: UIView!
    @IBOutlet var descriptionLabel: CustomLabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var joinerView: EventJoinersView!
    @IBOutlet var joinImageView: UIImageView!
    @IBOutlet var statusView: EventStatusView!

    private var model: EventDisplayModel?
    private var width: CGFloat?

    weak var delegate: EventCollectionViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        containerView.layer.cornerRadius = 20
        containerView.layer.shadowColor = UIColor.systemGray4.cgColor
        containerView.layer.shadowRadius = 12.0
        containerView.layer.shadowOpacity = 0.7
        containerView.layer.masksToBounds = false
        containerView.backgroundColor = .systemBackground

        backgroundColor = .clear
        contentView.backgroundColor = .clear

        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "EventPhotosPager")
    }

    func configure(_ model: DisplayModel, width: CGFloat) {
        guard let event = model as? EventDisplayModel else {
            // TODO: Add a placeholder
            return
        }

        self.model = event
        self.width = frame.size.width

        titleLabel.text = event.title

        joinerView.update(withModel: event.joiners)

        joinImageView.image = event.joined ? UIImage(named: "Button-Joined") : UIImage(named: "Button-Join")

//        statusLabel.text = event.status
//        timeLeftLabel.text = event.timeLeft

        tableView.reloadData()

        descriptionLabel.isHidden = true

        var description = "\(event.description)"
        descriptionLabel.text = description

        let lines = descriptionLabel.calculateMaxLines()

        if lines > 2 {
            description = "\(description) Read more"
            let attributedString = NSMutableAttributedString(string: "\(description)", attributes: nil)
            let linkRange = NSMakeRange(description.count - 9, 9)

            let linkAttributes: [NSAttributedString.Key: AnyObject] = [
                NSAttributedString.Key.foregroundColor: UIColor.blue,
                NSAttributedString.Key.link: "" as AnyObject]
            attributedString.setAttributes(linkAttributes, range: linkRange)

            descriptionLabel.attributedText = attributedString

            descriptionLabel.onCharacterTapped = { _, _ in
            }
        }
        descriptionLabel.isHidden = false

        joinImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapJoin)))

        statusView.update(withStatus: event.status)
    }

    // MARK: - Actions

    @objc
    private func didTapJoin() {
        guard let model,
              !model.joined else { return }
        delegate?.eventCollectionViewCell(didUpdateJoinStatusOfEvent: model)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension EventCollectionViewCell: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventPhotosPager")!
        cell.selectionStyle = .none

        if let model,
           let width {
            cell.contentConfiguration = UIHostingConfiguration {
                EventPagerRow(displayModel: model, width: width)
            }
        }

        return cell
    }
}

class CustomLabel: UILabel {
    let layoutManager = NSLayoutManager()
    let textContainer = NSTextContainer(size: CGSize.zero)
    var textStorage = NSTextStorage() {
        didSet {
            textStorage.addLayoutManager(layoutManager)
        }
    }

    var onCharacterTapped: ((_ label: UILabel, _ characterIndex: Int) -> Void)?

    let tapGesture = UITapGestureRecognizer()

    override var attributedText: NSAttributedString? {
        didSet {
            if let attributedText = attributedText {
                textStorage = NSTextStorage(attributedString: attributedText)
            } else {
                textStorage = NSTextStorage()
            }
        }
    }

    override var lineBreakMode: NSLineBreakMode {
        didSet {
            textContainer.lineBreakMode = lineBreakMode
        }
    }

    override var numberOfLines: Int {
        didSet {
            textContainer.maximumNumberOfLines = numberOfLines
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }

    func setUp() {
        isUserInteractionEnabled = true
        layoutManager.addTextContainer(textContainer)
        textContainer.lineFragmentPadding = 0
        textContainer.lineBreakMode = lineBreakMode
        textContainer.maximumNumberOfLines = numberOfLines
        tapGesture.addTarget(self, action: #selector(CustomLabel.labelTapped(_:)))
        addGestureRecognizer(tapGesture)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        textContainer.size = bounds.size
    }

    @objc func labelTapped(_ gesture: UITapGestureRecognizer) {
        guard gesture.state == .ended else {
            return
        }
        let locationOfTouch = gesture.location(in: gesture.view)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(x: (bounds.width - textBoundingBox.width) / 2 - textBoundingBox.minX,
                                          y: (bounds.height - textBoundingBox.height) / 2 - textBoundingBox.minY)
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouch.x - textContainerOffset.x, y: locationOfTouch.y - textContainerOffset.y)
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer,
                                                            in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)

        onCharacterTapped?(self, indexOfCharacter)
    }
}



