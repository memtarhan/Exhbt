//
//  FollowsViewController.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 06/09/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Combine
import SwiftUI
import UIKit

class FollowsViewController: BaseViewController, Nibbable {
    var viewModel: FollowsViewModel!

    @IBOutlet var collectionView: UICollectionView!

    private lazy var sections = FollowsSection.allCases
    private lazy var dataSource = generatedDataSource

    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupSubscribers()

        viewModel.loadFollowers(forUser: nil)
    }

    private var generatedDataSource: UICollectionViewDiffableDataSource<FollowsSection, DisplayModel> {
        let dataSource = UICollectionViewDiffableDataSource<FollowsSection, DisplayModel>(collectionView: collectionView) { _, indexPath, model in

            guard let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: FollowCollectionViewCell.reuseIdentifier, for: indexPath) as? FollowCollectionViewCell else {
                return UICollectionViewCell()
            }

            cell.configure(model)

            return cell
        }

        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SegmentedControlHeader.reuseIdentifier, for: indexPath) as? SegmentedControlHeader else {
                return nil
            }

            header.delegate = self

            header.titles = self.viewModel.segmentedControlTitles
            header.setSelectedSegment(0)

            return header
        }

        return dataSource
    }
}

private extension FollowsViewController {
    func setupUI() {
        view.backgroundColor = .systemBackground

        navigationController?.navigationBar.tintColor = .systemBlue
        navigationController?.navigationBar.barStyle = .default

        collectionView.dataSource = dataSource
        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.collectionViewLayout = createComponsitionalLayout()
        collectionView.register(UINib(nibName: FollowCollectionViewCell.reuseIdentifier, bundle: .main), forCellWithReuseIdentifier: FollowCollectionViewCell.reuseIdentifier)
        collectionView.register(UINib(nibName: SegmentedControlHeader.reuseIdentifier, bundle: .main), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SegmentedControlHeader.reuseIdentifier)

        startLoading()
    }

    func setupSubscribers() {
        viewModel.snapshotPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure:
                    self?.stopLoading(withResult: .failure(LoadingFailureType.getType()))
                    break
                }
            } receiveValue: { [weak self] snapshot in
                self?.dataSource.apply(snapshot, animatingDifferences: true)
                self?.stopLoading()
            }
            .store(in: &cancellables)
    }
}

// MARK: - ComponsitionalLayout

private extension FollowsViewController {
    func createComponsitionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { _, _ in
            self.createHorizontalRankSection(hasHeader: true)
        }
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 16
        layout.configuration = config
        return layout
    }
}

// MARK: - UICollectionViewDelegate

extension FollowsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        viewModel.willDisplayItem(atIndexPath: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.section != 0 else { return }
        viewModel.didSelectItem(atIndexPath: indexPath)
    }
}

// MARK: - SegmentedControlHeaderDelegate

extension FollowsViewController: SegmentedControlHeaderDelegate {
    func segmentedControlHeader(didChangeTo index: Int) {
        // viewModel.selectedSegmentIndex = index
        // viewModel.refresh()
    }
}
