//
//  PrizesViewController.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 16/01/2024.
//  Copyright © 2024 Exhbt LLC. All rights reserved.
//

import Combine
import SwiftUI
import UIKit

class PrizesViewController: BaseViewController, Nibbable {
    var viewModel: PrizesViewModel!

    var userId: Int?

    @IBOutlet var collectionView: UICollectionView!

    private lazy var dataSource = generatedDataSource
    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupSubscriptions()

        startLoading()
        viewModel.userId = userId
        viewModel.load()
    }

    private var generatedDataSource: UICollectionViewDiffableDataSource<PrizeSection, DisplayModel> {
        UICollectionViewDiffableDataSource<PrizeSection, DisplayModel>(collectionView: collectionView) { _, indexPath, model in
            let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "Prize", for: indexPath)
            guard let prize = model as? PrizeDisplayModel else { return cell }

            cell.contentConfiguration = UIHostingConfiguration {
                PrizeContentView(prize: prize)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: .gray.opacity(0.1), radius: 20)
            }

            return cell
        }
    }
}

// MARK: - Setup

private extension PrizesViewController {
    func setupUI() {
        navigationItem.title = "Prizes"
        navigationController?.navigationBar.tintColor = .systemBlue
        navigationController?.navigationBar.barStyle = .default

        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.collectionViewLayout = createComponsitionalLayout()

        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Prize")
    }

    func setupSubscriptions() {
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
                self?.stopLoading()
            }
            .store(in: &cancellables)

        viewModel.shouldNavigateToResult
            .receive(on: DispatchQueue.main)
            .sink { exhbtId in
                self.presentExhbtResult(withId: exhbtId)
            }
            .store(in: &cancellables)
    }
}

// MARK: - ComponsitionalLayout

private extension PrizesViewController {
    func createComponsitionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { _, _ in
            self.createPrizesSection()
        }
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 16
        layout.configuration = config
        return layout
    }
}

// MARK: - UICollectionViewDelegate

extension PrizesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.didSelectItem(atIndexPath: indexPath)
    }
}

// MARK: - Router

extension PrizesViewController: Router {}
