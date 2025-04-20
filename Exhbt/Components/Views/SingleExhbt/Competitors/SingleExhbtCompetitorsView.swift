//
//  SingleExhbtCompetitorsView.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 04/04/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Combine
import UIKit

protocol SingleExhbtCompetitorsViewDelegate: AnyObject {
    func willShowChooseCompetitors()
    func willShowJoinExhbt()
    func singleExhbtCompetitors(willViewUser user: Int)
}

class SingleExhbtCompetitorsView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var countDescriptionLabel: UILabel!
    @IBOutlet var expandButton: UIButton!
    @IBOutlet var competitorsView: HorizontalCompetitorsView!
    @IBOutlet var tableView: DynamiclySizedTableView!
    @IBOutlet var inviteCompetitorsButton: FilledButton!

    private var cancellables: Set<AnyCancellable> = []

    @Published var shouldExpand = CurrentValueSubject<Bool, Never>(false)

    private var verticalModels = [SingleExhbtVerticalCompetitorModel]()

    weak var delegate: SingleExhbtCompetitorsViewDelegate?

    private var displayMode: ExhbtDetailsDisplayMode = .viewing

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    func setup() {
        contentView = loadFromNib(String(describing: SingleExhbtCompetitorsView.self))
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.frame = bounds
        addSubview(contentView)

        contentView.backgroundColor = .clear
        backgroundColor = .clear

        expandButton.addTarget(self, action: #selector(didTapExpandButton), for: .touchUpInside)
        inviteCompetitorsButton.addTarget(self, action: #selector(didTapInviteCompetitors), for: .touchUpInside)
        inviteCompetitorsButton.isHidden = true

        let cell = UINib(nibName: SingleCompetitorTableViewCell.reuseIdentifier, bundle: nil)
        tableView.register(cell, forCellReuseIdentifier: SingleCompetitorTableViewCell.reuseIdentifier)

        let freeSpotCell = UINib(nibName: FreeSpotTableViewCell.reuseIdentifier, bundle: nil)
        tableView.register(freeSpotCell, forCellReuseIdentifier: FreeSpotTableViewCell.reuseIdentifier)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = 60

        competitorsView.delegate = self

        shouldExpand
            .receive(on: DispatchQueue.main)
            .sink { expanded in
                self.tableView.isHidden = !expanded
                self.competitorsView.isHidden = expanded
                let buttonImage = expanded ? UIImage(named: "Exhbt-chevron-top") : UIImage(named: "Exhbt-chevron-bottom")
                self.expandButton.setImage(buttonImage, for: .normal)
            }
            .store(in: &cancellables)
    }

    func update(withModel model: SingleExhbtCompetitorsModel, displayMode: ExhbtDetailsDisplayMode = .viewing) {
        self.displayMode = displayMode

        titleLabel.text = model.title
        countDescriptionLabel.text = model.countDescription
        verticalModels = model.verticalCompetitors
        update(withModels: model.horizontalCompetitors)

        if model.isOwn {
            self.displayMode = .editing

            inviteCompetitorsButton.title = "Invite Competitors"
            inviteCompetitorsButton.isEnabled = (model.status == .submissions)

        } else {
            self.displayMode = .viewing

            inviteCompetitorsButton.title = "Join Exhbt"
            inviteCompetitorsButton.isEnabled = (model.status == .submissions && model.canJoin)
        }

        inviteCompetitorsButton.isHidden = false

        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    func updateJoinButtonStatus(status: ExhbtStatus, canJoin: Bool, isOwn: Bool) {
        if status == .finished || status == .archived {
//            inviteCompetitorsButton.title = FollowingStatus.follow.buttonTitle
//            inviteCompetitorsButton.color = FollowingStatus.follow.buttonBackgroundColor
            inviteCompetitorsButton.isEnabled = false
        } else {
            inviteCompetitorsButton.isEnabled = true
        }

        inviteCompetitorsButton.isEnabled = canJoin || isOwn
    }

    private func update(withModels models: [SingleExhbtHorizontalCompetitorModel]) {
        let displayModels = models.enumerated().map { index, model in
            CompetitorPhotoDisplayModel(id: model.id, image: nil, photoURL: model.photo, status: model.accepted ? .accepted : .pending, index: index)
        }

        competitorsView.update(withModels: displayModels)
    }

    @objc
    private func didTapExpandButton() {
        shouldExpand.send(!shouldExpand.value)
    }

    @objc
    private func didTapInviteCompetitors() {
        switch displayMode {
        case .editing:
            delegate?.willShowChooseCompetitors()
        case .viewing:
            delegate?.willShowJoinExhbt()
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension SingleExhbtCompetitorsView: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        verticalModels.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        verticalModels[section].items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 || indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: SingleCompetitorTableViewCell.reuseIdentifier) as! SingleCompetitorTableViewCell
            let item = verticalModels[indexPath.section].items[indexPath.row]
            cell.update(withItem: item, status: indexPath.section == 0 ? .accepted : .pending)
            return cell

        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: FreeSpotTableViewCell.reuseIdentifier) as! FreeSpotTableViewCell
            let item = verticalModels[indexPath.section].items[indexPath.row]
            cell.update(withTitle: item.imageName!, name: item.name!)
            return cell
        }

        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        verticalModels[section].sectionTitle
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = verticalModels[indexPath.section].items[indexPath.row]
        guard let userId = item.id else { return }
        delegate?.singleExhbtCompetitors(willViewUser: userId)
    }
}

extension SingleExhbtCompetitorsView: HorizontalCompetitorsDelegate {
    func horizontalCompetitorsDidViewInfo() {
    }

    func horizontalCompetitors(willViewUser user: Int) {
        delegate?.singleExhbtCompetitors(willViewUser: user)
    }
}

class DynamiclySizedTableView: UITableView {
    override var intrinsicContentSize: CGSize {
        self.layoutIfNeeded()
        return self.contentSize
    }

    override var contentSize: CGSize {
        didSet {
            self.invalidateIntrinsicContentSize()
        }
    }

    override func reloadData() {
        super.reloadData()
        invalidateIntrinsicContentSize()
    }
}
