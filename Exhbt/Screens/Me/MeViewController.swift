//
//  MeViewController.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 12/05/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Combine
import SwiftUI
import UIKit

class MeViewController: BaseViewController, Nibbable {
    var viewModel: MeViewModel!

    @IBOutlet var collectionView: UICollectionView!
    private let refreshControl = UIRefreshControl()

    private lazy var sections = MeSection.allCases
    private lazy var dataSource = generatedDataSource
    private var cancellables: Set<AnyCancellable> = []

    private let items = [
        SegmentedControlItem(image: UIImage(systemName: "xmark")!, title: "Exhbts"),
        SegmentedControlItem(image: UIImage(systemName: "square.grid.3x3.topleft.filled")!, title: "Gallery"),
        SegmentedControlItem(image: UIImage(systemName: "calendar")!, title: "Events"),
        SegmentedControlItem(image: UIImage(systemName: "lock.shield")!, title: "Private"),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupSubscribers()

        viewModel.registerNotifications()
        viewModel.load()
    }

    // MARK: - Actions

    @objc
    private func didTapSettings(_ sender: UIBarButtonItem) {
        presentSettings()
    }

    @objc
    private func didPullToRefresh(_ sender: AnyObject) {
        refreshControl.beginRefreshing()
        viewModel.refreshAll()
    }

    private var generatedDataSource: UICollectionViewDiffableDataSource<MeSection, DisplayModel> {
        let dataSource = UICollectionViewDiffableDataSource<MeSection, DisplayModel>(collectionView: collectionView) { _, indexPath, model in

            switch indexPath.section {
            case 0:
                guard let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: ProfileDetailsCollectionViewCell.reuseIdentifier, for: indexPath) as? ProfileDetailsCollectionViewCell else {
                    return UICollectionViewCell()
                }

//                cell.contentConfiguration = UIHostingConfiguration {
//                    ProfileDetailsView(details: model as! MeDetailsDisplayModel)
//                }

                cell.delegate = self
                cell.configure(model)

                return cell

            case 1:
                let section = self.sections[self.viewModel.selectedSegmentIndex + 1]

                switch section {
                case .details:
                    return UICollectionViewCell()
                case .gallery:
                    guard let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: GalleryGridCollectionViewCell.resuseIdentifier, for: indexPath) as? GalleryGridCollectionViewCell else {
                        return UICollectionViewCell()
                    }

                    cell.tag = indexPath.row
                    cell.configure(model)

                    return cell
                case .events:
                    let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "EventRow", for: indexPath)
                    guard let event = model as? EventDisplayModel else { return cell }

                    cell.contentConfiguration = UIHostingConfiguration {
                        EventPreview(event: event) { [weak self] in
                            self?.viewModel.didSelectItem(atIndexPath: indexPath)
                        } onJoin: { [weak self] in
                            self?.startLoading()
                        }
                    }

                    return cell

                case .publicExhbts, .privateExhbts:
                    guard let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: ExhbtCollectionViewCell.reuseIdentifier, for: indexPath) as? ExhbtCollectionViewCell else {
                        return UICollectionViewCell()
                    }

                    cell.configure(model)

                    return cell
                }

            default:
                return UICollectionViewCell()
            }
        }

        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SegmentedControlHeader.reuseIdentifier, for: indexPath) as? SegmentedControlHeader else {
                return nil
            }

            header.delegate = self
            header.items = self.items
            header.setSelectedSegment(self.viewModel.selectedSegmentIndex)

            return header
        }

        return dataSource
    }
}

// MARK: - Setup

private extension MeViewController {
    func setupUI() {
        view.backgroundColor = .systemBackground
        navigationItem.title = "Profile"

        navigationController?.navigationBar.tintColor = .systemBlue
        navigationController?.navigationBar.barStyle = .default

        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.collectionViewLayout = createComponsitionalLayout()

        refreshControl.addTarget(self, action: #selector(didPullToRefresh(_:)), for: .valueChanged)
        collectionView.refreshControl = refreshControl

        collectionView.register(UINib(nibName: ProfileDetailsCollectionViewCell.reuseIdentifier, bundle: .main), forCellWithReuseIdentifier: ProfileDetailsCollectionViewCell.reuseIdentifier)
        collectionView.register(UINib(nibName: ExhbtCollectionViewCell.reuseIdentifier, bundle: .main), forCellWithReuseIdentifier: ExhbtCollectionViewCell.reuseIdentifier)
        collectionView.register(UINib(nibName: GalleryGridCollectionViewCell.resuseIdentifier, bundle: .main), forCellWithReuseIdentifier: GalleryGridCollectionViewCell.resuseIdentifier)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "EventRow")
        collectionView.register(UINib(nibName: SegmentedControlHeader.reuseIdentifier, bundle: .main), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SegmentedControlHeader.reuseIdentifier)

        let rightButtonItem = UIBarButtonItem(image: UIImage(systemName: "gearshape"),
                                              style: .plain,
                                              target: self,
                                              action: #selector(didTapSettings(_:)))
        navigationItem.rightBarButtonItem = rightButtonItem
    }

    func setupSubscribers() {
        viewModel.snapshotPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure:
                    self?.stopLoading(withResult: .failure(.getType()))
                    self?.refreshControl.endRefreshing()
                    break
                }
            } receiveValue: { [weak self] snapshot in
                self?.dataSource.apply(snapshot, animatingDifferences: true)
                self?.refreshControl.endRefreshing()
            }
            .store(in: &cancellables)

        viewModel.shouldNavigateToDetails
            .receive(on: DispatchQueue.main)
            .sink { exhbt in
                self.presentExhbt(withId: exhbt.id, displayMode: exhbt.isOwn ? .editing : .viewing)
            }
            .store(in: &cancellables)

        viewModel.shouldNavigateToResult
            .receive(on: DispatchQueue.main)
            .sink { exhbt in
                self.presentExhbtResult(withId: exhbt.id)
            }
            .store(in: &cancellables)

        viewModel.shouldNavigateToVoting
            .receive(on: DispatchQueue.main)
            .sink { _ in
                // TODO: Fix navigation to Voting
//                self.presentVoting(withExhbt: ?)
            }
            .store(in: &cancellables)

        viewModel.shouldNavigateToGalleryVertical
            .receive(on: DispatchQueue.main)
            .sink { items, selected in
                self.presentGalleryVertical(items, selected: selected)
            }
            .store(in: &cancellables)

        viewModel.shouldNavigateToEventDetails
            .receive(on: DispatchQueue.main)
            .sink { event in
                self.presentPosts(forEvent: event.id)
            }
            .store(in: &cancellables)

        viewModel.shouldNavigateToEventResult
            .receive(on: DispatchQueue.main)
            .sink { event in
                self.presentEventResult(eventId: event.id)
            }
            .store(in: &cancellables)
    }
}

// MARK: - ComponsitionalLayout

private extension MeViewController {
    func createComponsitionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, _ in
            let section = self.sections[sectionIndex]
            if section == .details {
                return self.createProfileDetailsSection()
            } else {
                let newSection = self.sections[self.viewModel.selectedSegmentIndex + 1]
                switch newSection {
                case .details:
                    return self.createProfileDetailsSection()
                case .gallery:
                    return self.createGallerySection(height: 36)
                case .events:
                    return self.createEventsSection(height: 36)
                case .publicExhbts, .privateExhbts:
                    return self.createExhbtsSection(height: 36)
                }
            }
        }
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 16
        layout.configuration = config
        return layout
    }
}

// MARK: - UICollectionViewDelegate

extension MeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        viewModel.willDisplayItem(atIndexPath: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.section != 0 else { return }
        viewModel.didSelectItem(atIndexPath: indexPath)
    }
}

// MARK: - SegmentedControlHeaderDelegate

extension MeViewController: SegmentedControlHeaderDelegate {
    func segmentedControlHeader(didChangeTo index: Int) {
        viewModel.selectedSegmentIndex = index
        viewModel.refresh()
    }
}

// MARK: - ProfileDetailsDelegate

extension MeViewController: ProfileDetailsDelegate {
    func navigateToEdit() {
        presentProfileAccount()
    }

    func profileDetails(didFollowUser user: ProfileDetailsDisplayModel) {}
    func profileDetails(didUnfollowUser user: ProfileDetailsDisplayModel) {}

    func profileDetails(willViewPrizes forUser: ProfileDetailsDisplayModel) {
        debugLog(self, #function)
        presentPrizes(forUser: forUser.id)
    }

    func profileDetails(willViewVotes forUser: ProfileDetailsDisplayModel) {
        debugLog(self, #function)
        presentVotes()
    }

    func profileDetails(willViewFollowers forUser: ProfileDetailsDisplayModel) {
        debugLog(self, #function)
        presentFollowers(withUser: nil, shouldShowFollowers: true)
    }

    func profileDetails(willViewFollowings forUser: ProfileDetailsDisplayModel) {
        debugLog(self, #function)
        presentFollowers(withUser: nil, shouldShowFollowers: false)
    }

    func profileDetails(willViewProfilePhoto forUser: ProfileDetailsDisplayModel) {
        debugLog(self, #function)
        if let urlString = forUser.profilePhotoURL,
           let url = URL(string: urlString) {
            let viewer = ImageViewerViewer(withURL: url)
            present(viewer, animated: true)
        }
    }
}

// MARK: - Router

extension MeViewController: Router { }
