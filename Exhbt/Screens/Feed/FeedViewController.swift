//
//  FeedViewController.swift
//  Exhbt
//
//  Created Mehmet Tarhan on 03/03/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import Combine
import UIKit

protocol FeedViewController: Injectable {
    var presenter: FeedPresenter? { get set }
}

class FeedViewControllerImpl: UIViewController {
    var presenter: FeedPresenter?

    @IBOutlet var tableView: UITableView!

    private var cancellables: Set<AnyCancellable> = []

    private let rowHeight: CGFloat = 280

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    func injectDependencies() {
        let presenter: FeedPresenter = FeedPresenterImpl()
        let interactor: FeedInteractor = FeedInteractorImpl()
        let router: FeedRouter = FeedRouterImpl()
        presenter.view = self
        presenter.interactor = interactor
        presenter.router = router
        interactor.presenter = presenter
        router.view = self

        self.presenter = presenter
    }

    // MARK: - Actions

    @objc func didTapNotifications(_ sender: UIBarButtonItem) {
    }

    private func setup() {
        let imageView = UIImageView(image: UIImage(named: "Logo full"))
        imageView.contentMode = .scaleAspectFit
        navigationItem.titleView = imageView

        let rightButtonItem = UIBarButtonItem(image: UIImage(named: "Navigation Bar - Notifications"),
                                              style: .plain,
                                              target: self,
                                              action: #selector(didTapNotifications(_:)))
        navigationItem.rightBarButtonItem = rightButtonItem

        let cell = UINib(nibName: FeedTableViewCell.nibIdentifier, bundle: nil)
        tableView.register(cell, forCellReuseIdentifier: FeedTableViewCell.reuseIdentifier)

        tableView.rowHeight = rowHeight
        tableView.delegate = self

        presenter?.triggerPublisher
            .receive(on: RunLoop.main)
            .sink { _ in
            }.store(in: &cancellables)

        presenter?.fetchCompletionPublisher
            .receive(on: RunLoop.main)
            .sink { result in
                if result {
                    // TODO: Implement stop loading indicator

                } else {
                    // TODO: Implement start loading indicator
                }

            }.store(in: &cancellables)

        presenter?.diffableDataSource = FeedsTableViewDiffableDataSource(tableView: tableView) { (tableView, indexPath, model) -> UITableViewCell? in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: FeedTableViewCell.reuseIdentifier, for: indexPath) as? FeedTableViewCell
            else { return UITableViewCell() }

            cell.configure(model)

            return cell
        }
    }
}

// MARK: - FeedViewController

extension FeedViewControllerImpl: FeedViewController {
}

// MARK: - UITableViewDelegate

extension FeedViewControllerImpl: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: Implement selection
    }
}
