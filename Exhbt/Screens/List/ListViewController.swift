//
//  ListViewController.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 28/03/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Combine
import UIKit

class ListViewController: UIViewController, Nibbable {
    @IBOutlet var collectionView: UICollectionView!

    private var sections = ListSection.allCases
    private let sectionTitles = ListSection.allCases.map { $0.rawValue }

    typealias snapshotType = NSDiffableDataSourceSnapshot<ListSection, ListItem>
    @Published var snapshot = CurrentValueSubject<snapshotType, Never>(snapshotType())

    private lazy var dataSource = generatedDataSource

    private var cancellables: Set<AnyCancellable> = []

    private var selectedSegmentIndex = 0

    private var leftPage = 1
    private var rightPage = 1

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.contentInsetAdjustmentBehavior = .never // To prevent space at the top at initial load
        collectionView.collectionViewLayout = createComponsitionalLayout()
        collectionView.register(UINib(nibName: HorizontalListItemCell.resuseIdentifier, bundle: .main), forCellWithReuseIdentifier: HorizontalListItemCell.resuseIdentifier)
        collectionView.register(UINib(nibName: VerticalListItemCell.resuseIdentifier, bundle: .main), forCellWithReuseIdentifier: VerticalListItemCell.resuseIdentifier)
        collectionView.register(UINib(nibName: SegmentedControlHeader.reuseIdentifier, bundle: .main), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SegmentedControlHeader.reuseIdentifier)

        snapshot.value.appendSections([.horizontal, .verticalLeft])

        snapshot
            .receive(on: DispatchQueue.main)
            .sink { snapshot in
                self.dataSource.apply(snapshot, animatingDifferences: true)
            }
            .store(in: &cancellables)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reloadData()
    }

    func createComponsitionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, _ in
            let section = self.sections[sectionIndex]

            switch section {
            case .horizontal:
                return self.createHorizontalSection(using: section)
            case .verticalLeft:
                return self.createVerticalSection(using: section)
            case .verticalRight:
                return self.createVerticalSection(using: section)
            }
        }

        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 8
        layout.configuration = config

        return layout
    }

    private func createHorizontalSection(using section: ListSection) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.8), heightDimension: .fractionalHeight(0.25))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging

        /// - Header
        section.boundarySupplementaryItems = [createSectionHeader(height: 48)]

        return section
    }

    private func createVerticalSection(using section: ListSection) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(72))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)

        return section
    }

    private var generatedDataSource: UICollectionViewDiffableDataSource<ListSection, ListItem> {
        let dataSource = UICollectionViewDiffableDataSource<ListSection, ListItem>(collectionView: collectionView) { _, indexPath, model in
            let section = self.sections[indexPath.section]

            switch section {
            case .horizontal:
                guard let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: HorizontalListItemCell.resuseIdentifier, for: indexPath) as? HorizontalListItemCell else {
                    fatalError("Unable to dequeue cell")
                }

                cell.titleLabel.text = model.title

                return cell

            case .verticalLeft:
                guard let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: VerticalListItemCell.resuseIdentifier, for: indexPath) as? VerticalListItemCell else {
                    fatalError("Unable to dequeue cell")
                }

                cell.titleLabel.text = model.title

                return cell

            case .verticalRight:
                guard let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: VerticalListItemCell.resuseIdentifier, for: indexPath) as? VerticalListItemCell else {
                    fatalError("Unable to dequeue cell")
                }

                cell.titleLabel.text = model.title

                return cell
            }
        }

        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SegmentedControlHeader.reuseIdentifier, for: indexPath) as? SegmentedControlHeader else {
                return nil
            }

            header.delegate = self

            // Customize header here

            return header
        }

        return dataSource
    }

    func reloadData() {
        let horizontalModels = Array(0 ... 10).map { ListItem(id: $0, title: "Horizontal #\($0)") }
        let leftModels = Array(0 ... 10).map { ListItem(id: $0, title: "Vertical #\($0)") }
        snapshot.value.appendItems(horizontalModels, toSection: .horizontal)
        snapshot.value.appendItems(leftModels, toSection: .verticalLeft)
    }
}

extension ListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            // Left
            if selectedSegmentIndex == 0 {
                let count = snapshot.value.itemIdentifiers(inSection: .verticalLeft).count
                if count <= indexPath.row + 2 {
                    leftPage += 1
                    debugLog(self, #function)
                    let more = Array(0 ... 10).map { ListItem(id: $0, title: "Vertical Page=\(leftPage) #\($0)") }
                    snapshot.value.appendItems(more, toSection: .verticalLeft)
                }

            } else if selectedSegmentIndex == 1 {
                let count = snapshot.value.itemIdentifiers(inSection: .verticalRight).count
                if count <= indexPath.row + 2 {
                    rightPage += 1
                    debugLog(self, #function)
                    let more = Array(0 ... 10).map { ListItem(id: $0, title: "Vertical Page=\(rightPage) #\($0)") }
                    snapshot.value.appendItems(more, toSection: .verticalRight)
                }
            }
        }
    }
}

extension ListViewController: SegmentedControlHeaderDelegate {
    func segmentedControlHeader(didChangeTo index: Int) {
        debugLog(self, index)

        selectedSegmentIndex = index

        if index == 0 {
            snapshot.value.deleteSections([.verticalRight])
            snapshot.value.appendSections([.verticalLeft])
            let verticalModels = Array(0 ... 10).map { ListItem(id: $0, title: "Vertical Left #\($0)") }
            snapshot.value.appendItems(verticalModels, toSection: .verticalLeft)

        } else if index == 1 {
            snapshot.value.deleteSections([.verticalLeft])
            snapshot.value.appendSections([.verticalRight])
            let verticalModels = Array(0 ... 10).map { ListItem(id: $0, title: "Vertical Right #\($0)") }
            snapshot.value.appendItems(verticalModels, toSection: .verticalRight)
        }
    }
}

struct ListItem {
    let id: Int
    let title: String
}

/// - to confirm DiffableDataSource
extension ListItem: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: ListItem, rhs: ListItem) -> Bool {
        return (lhs.id == rhs.id) && (lhs.title == rhs.title)
    }
}

enum ListSection: String, CaseIterable {
    case horizontal
    case verticalLeft
    case verticalRight
}
