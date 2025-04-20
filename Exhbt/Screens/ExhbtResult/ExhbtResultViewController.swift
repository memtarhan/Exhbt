//
//  ExhbtResultViewController.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 30/05/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Combine
import SPConfetti
import SwiftUI
import UIKit

class ExhbtResultViewController: BaseViewController, Nibbable {
    var viewModel: ExhbtResultViewModel!
    var exhbtId: Int?

    @IBOutlet var collectionView: UICollectionView!

    private lazy var sections = ExhbtResultSection.allCases
    private lazy var dataSource = generatedDataSource
    private var cancellables: Set<AnyCancellable> = []

    private var winnerSubview: (UIView & UIContentView)?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupSubscribers()
        viewModel.exhbtId = exhbtId
        viewModel.load()
    }

    private var generatedDataSource: UICollectionViewDiffableDataSource<ExhbtResultSection, DisplayModel> {
        let dataSource = UICollectionViewDiffableDataSource<ExhbtResultSection, DisplayModel>(collectionView: collectionView) { _, indexPath, model in

            let section = self.sections[indexPath.section]

            switch section {
            case .preview:
                guard let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: ExhbtCollectionViewCell.reuseIdentifier, for: indexPath) as? ExhbtCollectionViewCell else {
                    return UICollectionViewCell()
                }

                cell.configure(model)

                return cell

            case .topRank:
                guard let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: TopRanksCollectionViewCell.reuseIdentifier, for: indexPath) as? TopRanksCollectionViewCell else {
                    return UICollectionViewCell()
                }

                cell.contentConfiguration = UIHostingConfiguration {
                    RanksRow(data: model as! ExhbtResultTopRanksDisplayModel) { [weak self] userId in
                        self?.viewModel.didSelectUser(withId: userId)
                    }
                }
                .margins([.leading, .trailing], 20)

                return cell

            case .bottomRank:
                guard let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: LeaderboardUserCollectionViewCell.reuseIdentifier, for: indexPath) as? LeaderboardUserCollectionViewCell else {
                    return UICollectionViewCell()
                }

                if let user = model as? LeaderboardUserDisplayModel {
                    cell.configure(withUser: user, shouldHideRank: user.rankType == .regular)
                }

                return cell
            }
        }

        return dataSource
    }
}

// MARK: - Setup

private extension ExhbtResultViewController {
    func displayWinner(_ winner: WinnerModel) {
        navigationController?.navigationBar.isHidden = true

        let winnerContentView = WinnerView(winner: winner) {
            self.winnerSubview?.removeFromSuperview()
            self.displayResult()
            self.viewModel.loadResults()
        }

        let config = UIHostingConfiguration {
            winnerContentView
        }
        winnerSubview = config.makeContentView()

        guard let winnerSubview else { return }

        winnerSubview.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(winnerSubview)

        NSLayoutConstraint.activate([
            winnerSubview.topAnchor.constraint(equalTo: view.topAnchor),
            winnerSubview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            winnerSubview.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            winnerSubview.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    func displayResult() {
        navigationController?.navigationBar.isHidden = false

        navigationItem.title = "Congratulations Winners"

        navigationController?.navigationBar.tintColor = .systemBlue
        navigationController?.navigationBar.barStyle = .default

        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.collectionViewLayout = createComponsitionalLayout()

        collectionView.register(UINib(nibName: ExhbtCollectionViewCell.reuseIdentifier, bundle: .main), forCellWithReuseIdentifier: ExhbtCollectionViewCell.reuseIdentifier)
        collectionView.register(UINib(nibName: TopRanksCollectionViewCell.reuseIdentifier, bundle: .main), forCellWithReuseIdentifier: TopRanksCollectionViewCell.reuseIdentifier)
        collectionView.register(UINib(nibName: LeaderboardUserCollectionViewCell.reuseIdentifier, bundle: .main), forCellWithReuseIdentifier: LeaderboardUserCollectionViewCell.reuseIdentifier)

        startLoading()
    }

    func displayNoPermissionAlert() {
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.tintColor = .systemBlue
        navigationController?.navigationBar.barStyle = .default

        displayAlert(withTitle: "You cannot view this Exhbt", message: "You don't have permission to view this Exhbt", completion: {
            self.navigationController?.popViewController(animated: true)
        })
    }

    func setupSubscribers() {
        viewModel.shouldDismissResult
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.displayNoPermissionAlert()
            }
            .store(in: &cancellables)

        viewModel.winnerPublisher
            .receive(on: DispatchQueue.main)
            .sink { _ in
            } receiveValue: { winner in
                SPConfetti.startAnimating(.centerWidthToDown, particles: [.star], duration: 1)
                self.displayWinner(winner)
            }
            .store(in: &cancellables)

        viewModel.snapshotPublisher
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.stopLoading()
            } receiveValue: { snapshot in
                self.dataSource.apply(snapshot, animatingDifferences: true)
            }
            .store(in: &cancellables)

        viewModel.shouldDisplayUser
            .receive(on: RunLoop.main)
            .sink { [weak self] userId in
                self?.presentUser(withId: userId)
            }
            .store(in: &cancellables)
    }
}

// MARK: - ComponsitionalLayout

private extension ExhbtResultViewController {
    func createComponsitionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, _ in
            let section = self.sections[sectionIndex]
            switch section {
            case .preview:
                return self.createExhbtPreviewSection()
            case .topRank:
                return self.createExhbtTopRankSection()
            case .bottomRank:
                return self.createHorizontalRankSection(hasHeader: false)
            }
        }
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 16
        layout.configuration = config
        return layout
    }
}

// MARK: - UICollectionViewDelegate

extension ExhbtResultViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.didSelectItem(atIndexPath: indexPath)
    }
}

// MARK: - Router

extension ExhbtResultViewController: Router { }
