//
//  GalleryVerticalViewController.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 03/05/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import AVFoundation
import SwiftUI
import UIKit

class GalleryVerticalViewController: UIViewController, Nibbable {
    @IBOutlet var collectionView: UICollectionView!

    var items: [GalleryDisplayModel] = []
    var snapshot = gallerySnapshotType()
    var selected: Int?

    private var sections = GalleryGridSection.allCases
    private lazy var dataSource = generatedDataSource

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }

    @IBAction func didTapDismiss(_ sender: Any) {
        dismiss(animated: true)
    }

    private func setup() {
        view.backgroundColor = .black

//        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.collectionViewLayout = createComponsitionalLayout()

        collectionView.register(UINib(nibName: GalleryVerticalCollectionViewCell.reuseIdentifier, bundle: .main), forCellWithReuseIdentifier: GalleryVerticalCollectionViewCell.reuseIdentifier)

        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)

        let indexPath = IndexPath(row: selected ?? 0, section: 0)
        collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredVertically)
        collectionView.delegate?.collectionView?(collectionView, didSelectItemAt: indexPath)
    }

    func createComponsitionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { _, _ in
            self.createSection()
        }

        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.contentInsetsReference = .none
        config.scrollDirection = .horizontal
        config.interSectionSpacing = 16
        layout.configuration = config

        return layout
    }

    func createSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//        item.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 8, bottom: 0, trailing: 8)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging

        return section
    }

    private var generatedDataSource: UICollectionViewDiffableDataSource<GalleryGridSection, GalleryDisplayModel> {
        let dataSource = UICollectionViewDiffableDataSource<GalleryGridSection, GalleryDisplayModel>(collectionView: collectionView) { _, indexPath, model in

            guard let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: GalleryVerticalCollectionViewCell.reuseIdentifier, for: indexPath) as? GalleryVerticalCollectionViewCell else {
                return UICollectionViewCell()
            }

            cell.tag = indexPath.row

            if let videoURL = model.videoURL {
                cell.contentConfiguration = UIHostingConfiguration {
                    VideoContainerView(url: videoURL)
                }

            } else {
                cell.configure(with: model)
            }

            return cell
        }

        return dataSource
    }
}
