//
//  VotingViewController.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 17/05/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Combine
import UIKit

protocol VotingDelegate: AnyObject {
    func voting(didUpdateVoteStatus forFeed: FeedPreviewDisplayModel, count: Int, voted: Bool)
    func voting(didUpdateVoteStatus forCompetition: CompetitionDisplayModel)
}

class VotingViewController: BaseViewController, Nibbable {
    var viewModel: VotingViewModel!
    var feed: FeedPreviewDisplayModel?
    weak var delegate: VotingDelegate?

    @IBOutlet var collectionView: UICollectionView!

    private lazy var dataSource = generatedDataSource
    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let feed else {
            dismiss(animated: true)
            return
        }

        setupUI()
        setupSubscribers()

        viewModel.exhbtId = feed.id
        viewModel.load()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - Actions

    @objc
    private func didTapReport(_ sender: UIBarButtonItem) {
        ReportActionService.shared.reportActionServiceDidFinishReporting
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.viewModel.flag()
            }
            .store(in: &cancellables)
        ReportActionService.shared.display(on: self)
    }

    private var generatedDataSource: UICollectionViewDiffableDataSource<VotingSection, CompetitionDisplayModel> {
        let dataSource = UICollectionViewDiffableDataSource<VotingSection, CompetitionDisplayModel>(collectionView: collectionView) { _, indexPath, model in
            let section = self.viewModel.sections[indexPath.section]

            switch section {
            case .full:
                guard let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: VotingFullCollectionViewCell.reuseIdentifier, for: indexPath) as? VotingFullCollectionViewCell else {
                    return UICollectionViewCell()
                }

                cell.delegate = self
                cell.tag = indexPath.row * (indexPath.section + 1)
                cell.update(withModel: model)

                return cell

            case .thumbnail:
                guard let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: VotingThumbnailCollectionViewCell.reuseIdentifier, for: indexPath) as? VotingThumbnailCollectionViewCell else {
                    return UICollectionViewCell()
                }

                cell.tag = indexPath.row * (indexPath.section + 1)
                cell.update(withModel: model)

                return cell
            }
        }

        return dataSource
    }
}

// MARK: - Setup

private extension VotingViewController {
    func setupUI() {
        view.backgroundColor = .competitionBackgroundColor

        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.isHidden = false

        let reportButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis"),
                                           style: .done,
                                           target: self,
                                           action: #selector(didTapReport(_:)))
        navigationItem.rightBarButtonItems = [reportButton]

        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isScrollEnabled = false
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.collectionViewLayout = createComponsitionalLayout()

        collectionView.register(UINib(nibName: VotingFullCollectionViewCell.reuseIdentifier, bundle: .main), forCellWithReuseIdentifier: VotingFullCollectionViewCell.reuseIdentifier)
        collectionView.register(UINib(nibName: VotingThumbnailCollectionViewCell.reuseIdentifier, bundle: .main), forCellWithReuseIdentifier: VotingThumbnailCollectionViewCell.reuseIdentifier)
    }

    func setupSubscribers() {
        viewModel.title
            .receive(on: DispatchQueue.main)
            .sink { title in
                self.navigationItem.title = title
            }
            .store(in: &cancellables)

        viewModel.snapshotPublisher
            .receive(on: DispatchQueue.main)
            .sink { snapshot in
                self.dataSource.apply(snapshot, animatingDifferences: false)
            }
            .store(in: &cancellables)

        viewModel.exhbtVotesCount
            .receive(on: DispatchQueue.main)
            .sink { count in
                guard let exhbt = self.feed,
                      exhbt.voteCount != count else { return }

                self.delegate?.voting(didUpdateVoteStatus: exhbt, count: count, voted: count > exhbt.voteCount)
            }
            .store(in: &cancellables)

        viewModel.shouldDisplayVoteStyleViewer
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.presentVoteStyles(on: self)
            }
            .store(in: &cancellables)

        viewModel.didSelectItem
            .receive(on: DispatchQueue.main)
            .sink { index in
                self.collectionView.selectItem(at: IndexPath(row: index, section: 0), animated: false, scrollPosition: .centeredHorizontally)
                self.collectionView.selectItem(at: IndexPath(row: index, section: 1), animated: false, scrollPosition: .centeredHorizontally)
            }
            .store(in: &cancellables)
    }
}

// MARK: - ComponsitionalLayout

private extension VotingViewController {
    func createComponsitionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, _ in
            let section = self.viewModel.sections[sectionIndex]

            switch section {
            case .full:
                return self.createFullSection()
            case .thumbnail:
                return self.createThumbnailSection()
            }
        }

        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 0
        layout.configuration = config

        return layout
    }

    func createFullSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.9))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered

        section.visibleItemsInvalidationHandler = { [weak self] _, location, _ in
            guard let self = self else { return }
            let width = self.collectionView.bounds.width
            let scrollOffset = location.x
            let modulo = scrollOffset.truncatingRemainder(dividingBy: width)
            let tolerance = width / 5
            if modulo < tolerance {
                let currentPage = Int(scrollOffset / width)
                self.viewModel.didSelectItem(atPage: currentPage)
            }
        }

        return section
    }

    func createThumbnailSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.125), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.1))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)

        return section
    }
}

// MARK: - VotingDelegate

extension VotingViewController: VotingDelegate {
    func voting(didUpdateVoteStatus forFeed: FeedPreviewDisplayModel, count: Int, voted: Bool) {}

    func voting(didUpdateVoteStatus forCompetition: CompetitionDisplayModel) {
        viewModel.updateVoteStatus(forCompetition: forCompetition)
    }
}

// MARK: - VoteStyleViewerDelegate

extension VotingViewController: VoteStyleViewerDelegate {
    func voteStyleViewer(didSelectVoteStyle style: VoteStyle) {
        guard let competition = viewModel.currentlyVotedCompetition else { return }
        UserSettings.shared.voteStyle = style
        viewModel.update(voteStyle: style)
        viewModel.updateVoteStatus(forCompetition: competition)
    }

    func voteStyleViewer(didFailWithError error: Error) {
        self.stopLoading(withResult: .failure(.getType()))
    }
}

extension VotingViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.didSelectItem(atIndexPath: indexPath)
    }
}

// MARK: - Router

extension VotingViewController: Router { }
