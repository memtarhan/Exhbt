//
//  VotesViewController.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 20/05/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Combine
import UIKit

class VotesViewController: BaseViewController, Nibbable {
    var viewModel: VotesViewModel!
    var userId: Int?

    @IBOutlet var tableView: UITableView!

    private var cancellables: Set<AnyCancellable> = []

    private let rowHeight: CGFloat = 280

    private lazy var dataSource = generatedDataSource

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupSubscribers()

        viewModel.userId = userId
        viewModel.load()
    }

    private var generatedDataSource: FeedsTableViewDiffableDataSource {
        FeedsTableViewDiffableDataSource(tableView: tableView) { tableView, indexPath, model -> UITableViewCell? in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: FeedTableViewCell.reuseIdentifier, for: indexPath) as? FeedTableViewCell
            else { return UITableViewCell() }
            cell.configure(model)
            return cell
        }
    }
}

private extension VotesViewController {
    func setupUI() {
        navigationItem.title = "Votes"
        let cell = UINib(nibName: FeedTableViewCell.nibIdentifier, bundle: nil)
        tableView.register(cell, forCellReuseIdentifier: FeedTableViewCell.reuseIdentifier)
        tableView.rowHeight = rowHeight
        tableView.delegate = self
        tableView.dataSource = dataSource
        startLoading()
    }

    func setupSubscribers() {
        viewModel.snapshotPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    debugLog(self, "\(error)")
                    self?.stopLoading(withResult: .failure(.getType()))
                    break
                }
            } receiveValue: { [weak self] snapshot in
                self?.dataSource.apply(snapshot, animatingDifferences: false)
                self?.stopLoading()
            }
            .store(in: &cancellables)
    }
}

// MARK: - UITableViewDelegate

extension VotesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        viewModel.didSelectItem(atIndexPath: indexPath)
    }
}

extension VotesViewController: Router {}
