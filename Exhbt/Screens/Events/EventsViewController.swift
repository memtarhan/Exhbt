//
//  EventViewController.swift
//  Exhbt
//
//  Created by Adem Tarhan on 30.09.2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Combine
import SwiftUI
import UIKit

class EventsViewController: BaseViewController, Nibbable {
    var viewModel: EventsViewModel!
    var filterViewController: UIHostingController<FilterView>!

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var blurView: UIVisualEffectView!

    private let refreshControl = UIRefreshControl()

    private lazy var dataSource = generatedDataSource
    private lazy var sections = EventsSection.allCases

    var displayFilter = CurrentValueSubject<Bool, Never>(false)

    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupSubscribers()
        registerForKeyboardNotifications()

        viewModel.registerNotifications()
        viewModel.load()
    }

    // MARK: - Actions

    @objc
    private func didPullToRefresh(_ sender: AnyObject) {
        refreshControl.beginRefreshing()
        viewModel.refresh()
    }

    @objc
    private func didTapFilter(_ sender: UIBarButtonItem) {
        displayFilter.send(!displayFilter.value)
    }

    @objc
    private func keyboardWillShow(_ notificiation: NSNotification) {
        searchBar.showsCancelButton = true
    }

    @objc
    private func keyboardWillHide(_ notification: NSNotification) {
        searchBar.showsCancelButton = false
    }

    @objc
    private func didTapBlurView(_ sender: UITapGestureRecognizer) {
        searchBar.resignFirstResponder()
    }

    private var generatedDataSource: UICollectionViewDiffableDataSource<EventsSection, DisplayModel> {
        let dataSource = UICollectionViewDiffableDataSource<EventsSection, DisplayModel>(collectionView: collectionView) { _, indexPath, model in

            let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "EventRow", for: indexPath)
            guard let event = model as? EventDisplayModel else { return cell }
            
            // MARK: IMPORTANT
            /*
             For some reason (to be researched - contentConfiguration will stay the same even if data is updated.
             No matter changes to data, the same UI will be displayed as at launch. Do research on this.
             For this, we deinit contentConfiguration and create it again
             */
            cell.contentConfiguration = nil
            cell.contentConfiguration = UIHostingConfiguration {
                EventPreview(event: event) { [weak self] in
                    self?.viewModel.didSelectItem(atIndexPath: indexPath)
                } onJoin: { [weak self] in
                    self?.startLoading()
                    self?.viewModel.join(event: event)
                }
            }

            return cell
        }

        return dataSource
    }
}

private extension EventsViewController {
    func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Events"
        navigationController?.navigationBar.tintColor = .systemBlue

        refreshControl.addTarget(self, action: #selector(didPullToRefresh(_:)), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        collectionView.delegate = self
        collectionView.dataSource = dataSource
        collectionView.contentInsetAdjustmentBehavior = .automatic
        collectionView.collectionViewLayout = createComponsitionalLayout()
        collectionView.keyboardDismissMode = .onDrag

        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "EventRow")
//        collectionView.register(UINib(nibName: EventCollectionViewCell.reuseIdentifier, bundle: .main), forCellWithReuseIdentifier: EventCollectionViewCell.reuseIdentifier)

        searchBar.placeholder = "Search for Events"
        searchBar.delegate = self

        blurView.isHidden = true
        blurView.isUserInteractionEnabled = true
        blurView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapBlurView(_:))))

        startLoading()
    }

    func setupSubscribers() {
        displayFilter
            .receive(on: DispatchQueue.main)
            .sink { [weak self] display in
                display ? self?.showFilter() : self?.hideFilter()
            }
            .store(in: &cancellables)

        viewModel.snapshotPublisher
            .receive(on: DispatchQueue.main)
            .sink { snapshot in
                self.dataSource.apply(snapshot, animatingDifferences: false)
                self.stopLoading()
                self.refreshControl.endRefreshing()
            }
            .store(in: &cancellables)

        viewModel.shouldPresentDetails
            .receive(on: DispatchQueue.main)
            .sink { event in
                self.presentPosts(forEvent: event.id)
            }
            .store(in: &cancellables)

        viewModel.shouldPresentResult
            .receive(on: DispatchQueue.main)
            .sink { event in
                self.presentEventResult(eventId: event.id)
            }
            .store(in: &cancellables)

        viewModel.shouldDisplayEmptyState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.stopLoading()
                self?.displayEmptyState(withType: .events)
            }
            .store(in: &cancellables)

        viewModel.eligibleToJoinPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] eligible in
                self?.stopLoading()
                if !eligible {
                    self?.displayIneligibilityAlert(message: "You do not have enough coins to join this Event but you can earn coins with Flash game", completion: {
                        self?.dismiss(animated: true)
                        UserSettings.shared.shouldShowFlashAtLaunch = true
                        AppState.shared.shouldShowFlash.send()
                    })
                }
            }
            .store(in: &cancellables)

        viewModel.joinedPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] joined in
                self?.stopLoading()
                if !joined {
                    self?.displayAlert(withTitle: "Oops, failed to join", message: "Please, try again later.", completion: nil)
                }
            })
            .store(in: &cancellables)

        AppState.shared.updatedEventFilters
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.startLoading()
                self?.viewModel.refresh()
            }
            .store(in: &cancellables)
    }

    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector:
            #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func showFilter() {
        guard let filterView = filterViewController.view else {
            return
        }

        filterView.translatesAutoresizingMaskIntoConstraints = false

        addChild(filterViewController)
        view.addSubview(filterView)

        filterView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        filterView.layer.cornerRadius = 20

        NSLayoutConstraint.activate([
            filterView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            filterView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            filterView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
        ])
        filterViewController.didMove(toParent: self)

        filterView.alpha = 0
        blurView.alpha = 0
        blurView.isHidden = false

        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut) {
            filterView.alpha = 1
            self.blurView.alpha = 1
        }
    }

    func hideFilter() {
        guard let filterView = filterViewController.view else {
            return
        }

        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut) {
            filterView.alpha = 0
            self.blurView.alpha = 0
        } completion: { _ in
            filterView.removeFromSuperview()
            self.filterViewController.didMove(toParent: nil)
            self.blurView.isHidden = true
        }
    }
}

// MARK: - Create layout

private extension EventsViewController {
    func createComponsitionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { _, _ in
            self.createEventsSection()
        }

        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 8
        layout.configuration = config
        return layout
    }
}

// MARK: - UICollectionViewDelegate

extension EventsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        viewModel.didSelectItem(atIndexPath: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        viewModel.willDisplayItem(atIndexPath: indexPath)
    }
}

// MARK: - UISearchBarDelegate

extension EventsViewController: UISearchBarDelegate {
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

// MARK: - EventCollectionViewCellDelegate

extension EventsViewController: EventCollectionViewCellDelegate {
    func eventCollectionViewCell(didUpdateJoinStatusOfEvent event: EventDisplayModel) {
        startLoading()
        viewModel.join(event: event)
    }
}

// MARK: - EventViewController

extension EventsViewController: Router {}
