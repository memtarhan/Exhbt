//
//  ExploreViewController.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 11/05/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Combine
import SwiftUI
import UIKit

class ExhbtsViewController: BaseViewController, Nibbable {
    var viewModel: ExhbtsViewModel!

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var searchBar: UISearchBar!
    private let refreshControl = UIRefreshControl()

    private var sections = ExhbtsSection.allCases
    private lazy var dataSource = generatedDataSource
    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupSubscribers()

        viewModel.registerNotifications()
        viewModel.load()

        startLoading()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        Timer.scheduledTimer(withTimeInterval: 10, repeats: false) { _ in
            self.dismissEmtypState()
        }
    }

    // MARK: - Actions

    @objc
    private func didPullToRefresh(_ sender: AnyObject) {
        refreshControl.beginRefreshing()
        viewModel.refresh()
    }

    @objc
    private func keyboardWillShow(_ notificiation: NSNotification) {
        searchBar.showsCancelButton = true
    }

    @objc
    private func keyboardWillHide(_ notification: NSNotification) {
        searchBar.showsCancelButton = false
    }

    private var generatedDataSource: UICollectionViewDiffableDataSource<ExhbtsSection, DisplayModel> {
        let dataSource = UICollectionViewDiffableDataSource<ExhbtsSection, DisplayModel>(collectionView: collectionView) { _, indexPath, model in
            let section = self.sections[indexPath.section]
            switch section {
            case .tags:
                let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "HastagView", for: indexPath)
                cell.contentConfiguration = UIHostingConfiguration {
                    if let tagsModel = model as? TagsDisplayModel {
                        HastagsView(tags: tagsModel.tags) { [weak self] selectedTag in
                            self?.startLoading()
                            self?.viewModel.selectedTag = selectedTag
                            self?.viewModel.refresh()
                        }
                    }
                }
                return cell
            case .exhbts:
                guard let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: ExhbtCollectionViewCell.reuseIdentifier, for: indexPath) as? ExhbtCollectionViewCell else {
                    return UICollectionViewCell()
                }
                cell.configure(model)
                return cell
            }
        }
        return dataSource
    }
}

// MARK: - Setup

private extension ExhbtsViewController {
    func setupUI() {
        title = "Exhbts"
        navigationController?.navigationBar.tintColor = .systemBlue
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.hidesSearchBarWhenScrolling = true
        refreshControl.addTarget(self, action: #selector(didPullToRefresh(_:)), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        collectionView.delegate = self
        collectionView.contentInsetAdjustmentBehavior = .always
        collectionView.allowsMultipleSelection = true
        collectionView.collectionViewLayout = createComponsitionalLayout()
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "HastagView")
        collectionView.register(UINib(nibName: ExhbtCollectionViewCell.reuseIdentifier, bundle: .main), forCellWithReuseIdentifier: ExhbtCollectionViewCell.reuseIdentifier)

        searchBar.placeholder = "Search for Exhbts"
        searchBar.delegate = self
    }

    func setupSubscribers() {
        viewModel.reloadTags
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.dataSource.apply(self.viewModel.snapshot, animatingDifferences: true)
            }
            .store(in: &cancellables)

        viewModel.reloadExhbts
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.refreshControl.endRefreshing()
                self.dataSource.apply(self.viewModel.snapshot, animatingDifferences: true)
                self.stopLoading()
            }
            .store(in: &cancellables)

        viewModel.shouldNavigateToDetails
            .receive(on: DispatchQueue.main)
            .sink { exhbt in
                self.presentExhbt(withId: exhbt.id, displayMode: exhbt.isOwn ? .editing : .viewing)
            }
            .store(in: &cancellables)

        viewModel.shouldShowError
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.stopLoading(withResult: .failure(.getType()))
            }
            .store(in: &cancellables)

        viewModel.shouldDisplayEmptyState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.stopLoading()
                self?.displayEmptyState(withType: .exhbts)
            }
            .store(in: &cancellables)
    }
}

// MARK: - UISearchBarDelegate

extension ExhbtsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchBar.showsCancelButton = true
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        debugLog(self, "searchBar didCancel")
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        debugLog(self, "searchBar didSearch")
        searchBar.resignFirstResponder()
        startLoading()
        viewModel.searchBarDidSearch(keyword: searchBar.text)
    }
}

// MARK: - ComponsitionalLayout

private extension ExhbtsViewController {
    func createComponsitionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, _ in
            let section = self.sections[sectionIndex]
            switch section {
            case .exhbts:
                return self.createExhbtsSection()
            case .tags:
                return self.createTagsSection()
            }
        }
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 8
        layout.configuration = config
        return layout
    }
}

// MARK: - UICollectionViewDelegate

extension ExhbtsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        viewModel.willDisplayItem(atIndexPath: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.didSelectItem(atIndexPath: indexPath)
    }
}

// MARK: - Router

extension ExhbtsViewController: Router { }
