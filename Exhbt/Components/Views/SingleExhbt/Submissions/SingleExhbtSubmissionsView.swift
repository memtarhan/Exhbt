//
//  SingleExhbtSubmissionsView.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 04/04/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Combine
import UIKit

class SingleExhbtSubmissionsView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var countDescriptionLabel: UILabel!
    @IBOutlet var expandButton: UIButton!
    @IBOutlet var collectionView: DynamiclySizedCollectionView!

    @IBOutlet var collectionViewHeightConstraint: NSLayoutConstraint!

    private var cancellables: Set<AnyCancellable> = []

    @Published var shouldExpand = CurrentValueSubject<Bool, Never>(false)

    private var submissions = [SingleExhbtSubmissionModel]()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    func setup() {
        contentView = loadFromNib(String(describing: SingleExhbtSubmissionsView.self))
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.frame = bounds
        addSubview(contentView)

        contentView.backgroundColor = .clear
        backgroundColor = .clear

        expandButton.addTarget(self, action: #selector(didTapExpandButton), for: .touchUpInside)

        let cell = UINib(nibName: SingleSubmissionCollectionViewCell.reuseIdentifier, bundle: nil)
        collectionView.register(cell, forCellWithReuseIdentifier: SingleSubmissionCollectionViewCell.reuseIdentifier)

        collectionView.delegate = self
        collectionView.dataSource = self

        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let width = (frame.width) / 3
        let height = width * 1.4 - 12
        layout.itemSize = CGSize(width: width, height: height)
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        collectionView!.collectionViewLayout = layout

        shouldExpand
            .receive(on: DispatchQueue.main)
            .sink { expanded in
                self.collectionView.isHidden = !expanded

                let buttonImage = expanded ? UIImage(named: "Exhbt-chevron-top") : UIImage(named: "Exhbt-chevron-bottom")
                self.expandButton.setImage(buttonImage, for: .normal)
            }
            .store(in: &cancellables)
    }

    func update(withModel model: SingleExhbtSubmissionsModel) {
        submissions = model.submissions

        titleLabel.text = model.title
        countDescriptionLabel.text = model.countDescription
        expandButton.isEnabled = !model.isLocked

        // TODO: Optimize static sizing
        let width = (frame.width - 24) / 3
        let height = width * 1.4
        let count = CGFloat(submissions.count / 3)
        collectionViewHeightConstraint.constant = (height * count) + (12 * count)

        collectionView.reloadData()
    }

    @objc
    private func didTapExpandButton() {
        shouldExpand.send(!shouldExpand.value)
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension SingleExhbtSubmissionsView: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        submissions.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SingleSubmissionCollectionViewCell.reuseIdentifier, for: indexPath) as! SingleSubmissionCollectionViewCell
        cell.configure(withModel: submissions[indexPath.row])

        return cell
    }
}

class DynamiclySizedCollectionView: UICollectionView {
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
