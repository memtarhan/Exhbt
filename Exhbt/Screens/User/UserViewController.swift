//
//  UserViewController.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 13/05/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Combine
import SwiftUI
import UIKit

class UserViewController: BaseViewController, Nibbable {
    var viewModel: UserViewModel!
    var userId: Int?

    @IBOutlet var collectionView: UICollectionView!

    private lazy var sections = UserSection.allCases
    private lazy var dataSource = generatedDataSource
    private var cancellables: Set<AnyCancellable> = []

    private let items = [
        SegmentedControlItem(image: UIImage(systemName: "xmark")!, title: "Exhbts"),
        SegmentedControlItem(image: UIImage(systemName: "square.grid.3x3.topleft.filled")!, title: "Gallery"),
        SegmentedControlItem(image: UIImage(systemName: "calendar")!, title: "Events"),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let userId else {
            dismiss(animated: true)
            return
        }

        setupUI()
        setupSubscribers()

        viewModel.userId = userId
        viewModel.loadDetails()
        viewModel.loadPublicExhbts()
    }

    // MARK: - Actions

    @objc
    private func didTapMore(_ sender: UIBarButtonItem) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let blockAction = UIAlertAction(title: "Block", style: .destructive) { _ in
            // TODO: Implement block user
            self.navigationController?.popViewController(animated: true)
        }
        actionSheet.addAction(blockAction)

        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(actionSheet, animated: true)
    }

    private var generatedDataSource: UICollectionViewDiffableDataSource<UserSection, DisplayModel> {
        let dataSource = UICollectionViewDiffableDataSource<UserSection, DisplayModel>(collectionView: collectionView) { _, indexPath, model in

            switch indexPath.section {
            case 0:
                guard let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: ProfileDetailsCollectionViewCell.reuseIdentifier, for: indexPath) as? ProfileDetailsCollectionViewCell else {
                    return UICollectionViewCell()
                }

                cell.delegate = self
                cell.configure(model)

                self.navigationItem.title = (model as? ProfileDetailsDisplayModel)?.username

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
                case .publicExhbts:
                    guard let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: ExhbtCollectionViewCell.reuseIdentifier, for: indexPath) as? ExhbtCollectionViewCell else {
                        return UICollectionViewCell()
                    }

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

private extension UserViewController {
    func setupUI() {
        view.backgroundColor = .systemBackground

        navigationController?.navigationBar.tintColor = .systemBlue
        navigationController?.navigationBar.barStyle = .default

        let moreButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis"),
                                         style: .done,
                                         target: self,
                                         action: #selector(didTapMore(_:)))
        navigationItem.rightBarButtonItems = [moreButton]

        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.collectionViewLayout = createComponsitionalLayout()

        collectionView.register(UINib(nibName: ProfileDetailsCollectionViewCell.reuseIdentifier, bundle: .main), forCellWithReuseIdentifier: ProfileDetailsCollectionViewCell.reuseIdentifier)
        collectionView.register(UINib(nibName: ExhbtCollectionViewCell.reuseIdentifier, bundle: .main), forCellWithReuseIdentifier: ExhbtCollectionViewCell.reuseIdentifier)
        collectionView.register(UINib(nibName: GalleryGridCollectionViewCell.resuseIdentifier, bundle: .main), forCellWithReuseIdentifier: GalleryGridCollectionViewCell.resuseIdentifier)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "EventRow")
        collectionView.register(UINib(nibName: SegmentedControlHeader.reuseIdentifier, bundle: .main), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SegmentedControlHeader.reuseIdentifier)
    }

    func setupSubscribers() {
        viewModel.usernamePublisher
            .receive(on: DispatchQueue.main)
            .sink { username in
                self.navigationItem.title = username
                self.navigationController?.title = username
            }
            .store(in: &cancellables)

        viewModel.snapshotPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure:
                    self?.stopLoading(withResult: .failure(.getType()))
                    break
                }
            } receiveValue: { [weak self] snapshot in
                self?.dataSource.apply(snapshot, animatingDifferences: true)
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
//                self.presentExhbt(withId: exhbt.id, displayMode: exhbt.isOwn ? .editing : .viewing)
            }
            .store(in: &cancellables)

        viewModel.shouldNavigateToVoting
            .receive(on: DispatchQueue.main)
            .sink { _ in
                // TODO: Fix navigation to Voting
//                self.presentVoting(withExhbt: ?)
//                self.presentExhbt(withId: exhbt.id, displayMode: exhbt.isOwn ? .editing : .viewing)
            }
            .store(in: &cancellables)

        viewModel.shouldNavigateToGalleryVertical
            .receive(on: DispatchQueue.main)
            .sink { items, selected in
                self.presentGalleryVertical(items, selected: selected)
            }
            .store(in: &cancellables)

        viewModel.shouldNavigateToEventDetails
            .receive(on: RunLoop.main)
            .sink { event in
                self.presentPosts(forEvent: event.id)
            }
            .store(in: &cancellables)

        viewModel.shouldNavigateToEventResult
            .receive(on: RunLoop.main)
            .sink { event in
                self.presentEventResult(eventId: event.id)
            }
            .store(in: &cancellables)
    }
}

// MARK: - ComponsitionalLayout

private extension UserViewController {
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
                case .publicExhbts:
                    return self.createExhbtsSection(height: 36)
                case .events:
                    return self.createEventsSection(height: 36)
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

extension UserViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        viewModel.willDisplayItem(atIndexPath: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.section != 0 else { return }
        viewModel.didSelectItem(atIndexPath: indexPath)
    }
}

// MARK: - SegmentedControlHeaderDelegate

extension UserViewController: SegmentedControlHeaderDelegate {
    func segmentedControlHeader(didChangeTo index: Int) {
        viewModel.selectedSegmentIndex = index
        viewModel.refresh()
    }
}

// MARK: - ProfileDetailsDelegate

extension UserViewController: ProfileDetailsDelegate {
    func navigateToEdit() {
        presentSettings()
    }

    func profileDetails(didFollowUser user: ProfileDetailsDisplayModel) {
        viewModel.willUpdateFollow(user)
    }

    func profileDetails(didUnfollowUser user: ProfileDetailsDisplayModel) {
        let actionSheet = UIAlertController(title: "Unfollow", message: "Are you sure you want to unfollow \(user.username)", preferredStyle: .actionSheet)

        let unfollowAction = UIAlertAction(title: "Unfollow", style: .default) { [weak self] _ in
            self?.viewModel.willUpdateFollow(user)
        }
        actionSheet.addAction(unfollowAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        actionSheet.addAction(cancelAction)

        present(actionSheet, animated: true)
    }

    func profileDetails(willViewPrizes forUser: ProfileDetailsDisplayModel) {
        debugLog(self, #function)
        presentPrizes(forUser: forUser.id)
    }

    func profileDetails(willViewVotes forUser: ProfileDetailsDisplayModel) {
        debugLog(self, #function)
        presentVotes(withUser: forUser.id)
    }

    func profileDetails(willViewFollowers forUser: ProfileDetailsDisplayModel) {
        debugLog(self, #function)
        presentFollowers(withUser: forUser, shouldShowFollowers: true)
    }

    func profileDetails(willViewFollowings forUser: ProfileDetailsDisplayModel) {
        debugLog(self, #function)
        presentFollowers(withUser: forUser, shouldShowFollowers: false)
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

extension UserViewController: Router { }
