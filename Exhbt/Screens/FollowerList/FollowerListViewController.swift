//
//  FollowerListViewController.swift
//  Exhbt
//
//  Created by Rakhmatov Bekzod on 03/05/23.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Combine
import UIKit

class FollowerListViewController: BaseViewController, Nibbable {
    var viewModel: FollowListViewModel!
    var user: ProfileDetailsDisplayModel?
    var shouldShowFollowers = true

    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBarView: UISearchBar!
    @IBOutlet var segmentControl: UISegmentedControl!
    @IBOutlet var emptyView: UIView!
    @IBOutlet var emptyLabel: UILabel!

    private lazy var dataSource = generatedDataSource
    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.userId = user?.id
        viewModel.shouldShowFollowers = shouldShowFollowers
        setup()
        handleSegmentChange()
    }

    @IBAction func didChangeSegmentedControl(_ sender: UISegmentedControl) {
        shouldShowFollowers = sender.selectedSegmentIndex == 0
        handleSegmentChange()
    }

    private func handleSegmentChange() {
        viewModel.shouldShowFollowers = shouldShowFollowers
        startLoading()
        viewModel.refreshed.send(true)
        emptyLabel.text = shouldShowFollowers ? "No Followers" : "No Followings"
    }

    private func setup() {
        segmentControl.selectedSegmentIndex = shouldShowFollowers ? 0 : 1
        emptyView.isHidden = true
        let cell = UINib(nibName: FollowerListCell.resuseIdentifier, bundle: nil)
        tableView.register(cell, forCellReuseIdentifier: FollowerListCell.resuseIdentifier)
        tableView.dataSource = dataSource
        tableView.delegate = self
        searchBarView.delegate = self
        if let user {
            navigationItem.title = user.username
            segmentControl.setTitle("\(user.followersCount) Followers", forSegmentAt: 0)
            segmentControl.setTitle("\(user.followingCount) Following", forSegmentAt: 1)
        }

        viewModel.snapshot
            .receive(on: DispatchQueue.main)
            .sink { _ in
            } receiveValue: { [weak self] snapshot in
                guard let self = self else { return }
                self.dataSource.apply(snapshot, animatingDifferences: false)
            }
            .store(in: &cancellables)
        viewModel.didFinishLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.stopLoading()
            }
            .store(in: &cancellables)
    }

    private var generatedDataSource: FollowerListTableViewDiffableDataSource {
        FollowerListTableViewDiffableDataSource(tableView: tableView) { tableView, indexPath, model -> UITableViewCell? in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: FollowerListCell.resuseIdentifier, for: indexPath) as? FollowerListCell
            else { return UITableViewCell() }
            cell.configureUser(with: model, on: self)
            return cell
        }
    }
}

extension FollowerListViewController: FollowerListCellDelegate {
    func didTapFollow(user: FollowerDisplayModel) {
        viewModel.willUpdateFollow(user)
    }

    func didTapFollowing(user: FollowerDisplayModel) {
        viewModel.willUpdateFollow(user)
    }
}

extension FollowerListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        performSearch()
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.keyword = searchText
        if searchText.isEmpty {
            performSearch()
        }
    }

    private func performSearch() {
        startLoading()
        viewModel.refreshed.send(true)
    }
}

extension FollowerListViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let scrollViewHeight = scrollView.frame.height
        if offsetY + scrollViewHeight >= contentHeight {
            viewModel.page.send(viewModel.page.value + 1)
        }
    }
}

extension FollowerListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectAllRows()
        if let userId = viewModel.getSelectedUserId(indexPath.row) {
            presentUser(withId: userId)
        }
    }
}

extension FollowerListViewController: Router {}
