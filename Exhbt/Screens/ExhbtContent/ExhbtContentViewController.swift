//
//  ExhbtContentViewController.swift
//  Exhbt
//
//  Created by Adem Tarhan on 18.09.2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import AVFoundation
import Combine
import SwiftUI
import UIKit

class ExhbtContentViewController: BaseViewController, Nibbable {
    var viewModel: ExhbtContentViewModel!

    @IBOutlet var collectionView: UICollectionView!

    var model: ExhbtPreviewDisplayModel!
    private lazy var dataSource = generatedDataSource
    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupSubscribers()
        viewModel.exhbtModel = model
        viewModel.load()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barStyle = .black
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    private var generatedDataSource: UICollectionViewDiffableDataSource<ExhbtContentSection, ExhbtContentDisplayModel> {
        let dataSource = UICollectionViewDiffableDataSource<ExhbtContentSection, ExhbtContentDisplayModel>(collectionView: collectionView) { _, indexPath, model in
            let section = self.viewModel.sections[indexPath.section]

            switch section {
            case .full:

                guard let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: ExhbtContentFullCollectionViewCell.reuseIdentifier, for: indexPath) as? ExhbtContentFullCollectionViewCell else {
                    return UICollectionViewCell()
                }

                cell.tag = indexPath.row * (indexPath.section + 1)

                if let videoURL = model.videoURL,
                   let url = URL(string: videoURL) {
                    cell.contentConfiguration = UIHostingConfiguration {
                        VideoContainerView(url: url)
                    }

                } else {
                    cell.update(withModel: model)
                }

                return cell

            case .thumbnail:
                guard let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: ExhbtContentThumbnailCollectionViewCell.reuseIdentifier, for: indexPath) as? ExhbtContentThumbnailCollectionViewCell else {
                    return UICollectionViewCell()
                }

                cell.tag = indexPath.row * (indexPath.section + 1)
                cell.update(withModel: model)

                return cell
            }
        }

        return dataSource
    }

    func setupUI() {
        navigationItem.title = "Content"
        view.backgroundColor = .competitionBackgroundColor

        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isScrollEnabled = false
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.collectionViewLayout = createComponsitionalLayout()

        collectionView.register(UINib(nibName: ExhbtContentFullCollectionViewCell.reuseIdentifier, bundle: .main), forCellWithReuseIdentifier: ExhbtContentFullCollectionViewCell.reuseIdentifier)
        collectionView.register(UINib(nibName: ExhbtContentThumbnailCollectionViewCell.reuseIdentifier, bundle: .main), forCellWithReuseIdentifier: ExhbtContentThumbnailCollectionViewCell.reuseIdentifier)
    }

    func setupSubscribers() {
        viewModel.snapshotPublisher
            .receive(on: DispatchQueue.main)
            .sink { snapshot in
                self.dataSource.apply(snapshot, animatingDifferences: false)
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

private extension ExhbtContentViewController {
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
        item.contentInsets = NSDirectionalEdgeInsets(top: 7, leading: 4, bottom: 7, trailing: 4)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.1))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)

        return section
    }
}

extension ExhbtContentViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.didSelectItem(atIndexPath: indexPath)
    }
}
