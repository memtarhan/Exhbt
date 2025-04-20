//
//  FeedViewController.swift
//  Exhbt
//
//  Created Mehmet Tarhan on 03/03/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import Combine
import UIKit
import YPImagePicker

class FeedsViewController: BaseViewController, Nibbable {
    var viewModel: FeedsViewModel!

    @IBOutlet var tableView: UITableView!

    private let refreshControl = UIRefreshControl()

    private var cancellables: Set<AnyCancellable> = []

    private let rowHeight: CGFloat = 300

    private lazy var dataSource = generatedDataSource

    @Published var refreshed: Bool = false

    private var currentlyPresentedIndexPath: IndexPath?

    // TODO: - Optimize it
    private let maxNumberOfPost = 30

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupSubscribers()
        registerNotifications()

        viewModel.load()
        startLoading()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.navigationBar.tintColor = .systemBlue
        navigationController?.navigationBar.barStyle = .default
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

//        for indexPath in tableView.indexPathsForVisibleRows ?? [] {
//            let indexPaths = [indexPath, IndexPath(row: indexPath.row - 1, section: indexPath.section), IndexPath(row: indexPath.row + 1, section: indexPath.section)]
//            indexPaths.forEach { [weak self] path in
//                if let self = self {
//                    if let cell = self.tableView.cellForRow(at: path) {
//                        (cell as? FeedTableViewCell)?.playLiveAnimation()
//                    }
//                }
//            }
//        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    // MARK: - Actions

    @objc func didPullToRefresh(_ sender: AnyObject) {
        refreshControl.beginRefreshing()
        viewModel.refresh()
    }

    @objc func didTapRefresh(_ sender: UIButton) {
        startLoading()
        refreshControl.beginRefreshing()
        viewModel.refresh()
    }

    @objc func didUpdateCompetition(_ sender: Notification) {
        viewModel.refresh()
        if let voteCount = sender.userInfo?["voteCount"] as? Int,
           let voted = sender.userInfo?["voted"] as? Bool {
            updateCompetition(voteCount, voted: voted)
        }
    }

    // MARK: - Actions

    @objc
    private func didTapSwipe(_ sender: UIBarButtonItem) {
        debugLog(self, #function)
        UserSettings.shared.shouldShowFlashAtLaunch = true
        (tabBarController as? TabBarViewController)?.setup()
    }

    private func updateCompetition(_ voteCount: Int, voted: Bool) {
        guard let currentlyPresentedIndexPath = currentlyPresentedIndexPath else {
            return
        }
        viewModel.updateCompetition(atIndex: currentlyPresentedIndexPath.row, voteCount: voteCount, voted: voted)
    }

    private var generatedDataSource: FeedsTableViewDiffableDataSource {
        FeedsTableViewDiffableDataSource(tableView: tableView) { tableView, indexPath, model -> UITableViewCell? in

            guard let cell = tableView.dequeueReusableCell(withIdentifier: FeedTableViewCell.reuseIdentifier, for: indexPath) as? FeedTableViewCell
            else { return UITableViewCell() }
            cell.delegate = self
            cell.configure(model)
            return cell
        }
    }
}

extension FeedsViewController: FeedTableViewCellDelegate {
    func feedTableViewCell(didSelectCategory category: Category) {
        debugLog(#function)
    }

    func feedTableViewCell(didTapPicture image: UIImage?) {
        debugLog(#function)
    }
}

private extension FeedsViewController {
    func setupUI() {
        let cell = UINib(nibName: FeedTableViewCell.nibIdentifier, bundle: nil)
        tableView.register(cell, forCellReuseIdentifier: FeedTableViewCell.reuseIdentifier)
        tableView.rowHeight = rowHeight
        tableView.delegate = self
        tableView.dataSource = dataSource
        refreshControl.addTarget(self, action: #selector(didPullToRefresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }

    func setupSubscribers() {
        viewModel.snapshotPublisher
            .receive(on: DispatchQueue.main)
            .sink { _ in
//                switch completion {
//                case .finished: 
//                    break
//                case .failure:
//                    break
////                    guard let self = self else { return }
////                    self.stopLoading(withResult: .failure(LoadingFailureType.getType()))
//                }
            } receiveValue: { [weak self] snapshot in
                self?.dataSource.apply(snapshot, animatingDifferences: false)
                self?.stopLoading()
                self?.refreshControl.endRefreshing()
            }
            .store(in: &cancellables)

        viewModel.noMoreExhbts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.stopLoading()
            }
            .store(in: &cancellables)

        viewModel.shouldPresentVoting
            .receive(on: DispatchQueue.main)
            .sink { [weak self] exhbt in
                self?.presentVoting(withExhbt: exhbt, delegate: self)
            }
            .store(in: &cancellables)

        viewModel.shouldDisplayEmptyState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.stopLoading()
                self?.displayEmptyState(withType: .feeds)
            }
            .store(in: &cancellables)
    }

    func registerNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didUpdateCompetition(_:)),
            name: .didUpdateCompetition,
            object: nil)
    }
}

// MARK: - UITableViewDelegate

extension FeedsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectItem(atIndexPath: indexPath)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        viewModel.willDisplayItem(atIndexPath: indexPath)
    }
}

extension FeedsViewController: VotingDelegate {
    func voting(didUpdateVoteStatus forFeed: FeedPreviewDisplayModel, count: Int, voted: Bool) {
        debugLog(self, "didUpdateVoteStatus forFeed \(forFeed.id)")
        viewModel.updateVoteStatus(forItem: forFeed, count: count, voted: voted)
    }

    func voting(didUpdateVoteStatus forCompetition: CompetitionDisplayModel) {}
}

// MARK: - Router

extension FeedsViewController: Router {}
