//
//  ExploreSearchViewController.swift
//  Exhbt
//
//  Created by Bekzod Rakhmatov on 16/06/23.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import UIKit
import Combine

class ExploreSearchViewController: BaseViewController, Nibbable {
    
    @IBOutlet var segmentControl: UISegmentedControl!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var emptyView: UIView!
    @IBOutlet var emptyLabel: UILabel!
    
    var viewModel: ExploreSearchViewModel!
    var searchQuery = ""
    var category: Category = .all
    private lazy var exhbtsDataSource = generateExhbtsDataSource
    private lazy var usersDataSource = generateUsersDataSource
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = searchQuery
        viewModel.searchQuery = searchQuery
        viewModel.category = category
        setUpcollectionView()
        setUpcollectionViewDataSource()
        setupSubscribers()
    }
    
    private func setupSubscribers() {
        viewModel.exhbtsSnapshotPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.showLoader(isLoading: false)
                    break
                case .failure(let error):
                    debugLog(self, "\(error)")
                    self?.stopLoading(withResult: .failure(.getType()))
                    break
                }
            } receiveValue: { [weak self] snapshot in
                self?.showLoader(isLoading: false)
                self?.exhbtsDataSource.apply(snapshot, animatingDifferences: false)
            }
            .store(in: &cancellables)
        viewModel.usersSnapshotPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.showLoader(isLoading: false)
                    break
                case .failure(let error):
                    debugLog(self, "\(error)")
                    self?.stopLoading(withResult: .failure(.getType()))
                    break
                }
            } receiveValue: { [weak self] snapshot in
                self?.showLoader(isLoading: false)
                self?.usersDataSource.apply(snapshot, animatingDifferences: false)
            }
            .store(in: &cancellables)
        viewModel.willDisplayUser
            .receive(on: DispatchQueue.main)
            .sink { [weak self] userId in
                self?.collectionView.deselectAllItems()
                self?.presentUser(withId: userId)
            }
            .store(in: &cancellables)
        viewModel.shouldNavigateToDetails
            .receive(on: DispatchQueue.main)
            .sink { exhbt in
                self.presentExhbt(withId: exhbt.id, displayMode: exhbt.isOwn ? .editing : .viewing)
            }
            .store(in: &cancellables)
    }
    
    private func showLoader(isLoading: Bool) {
        if segmentControl.selectedSegmentIndex == 0 {
            emptyView.isHidden = isLoading ? true : viewModel.exhbtsSnapshot.numberOfItems > 0
        } else {
            emptyView.isHidden = isLoading ? true : viewModel.usersSnapshot.numberOfItems > 0
        }
        activityIndicator.isHidden = isLoading ? false : true
    }
    
    private func setUpcollectionView() {
        collectionView.delegate = self
        collectionView.contentInsetAdjustmentBehavior = .always
        collectionView.collectionViewLayout = createComponsitionalLayout()
        collectionView.register(UINib(nibName: ExhbtCollectionViewCell.reuseIdentifier, bundle: .main), forCellWithReuseIdentifier: ExhbtCollectionViewCell.reuseIdentifier)
        collectionView.register(UINib(nibName: ExploreSearchCollectionViewCell.reuseIdentifier, bundle: .main), forCellWithReuseIdentifier: ExploreSearchCollectionViewCell.reuseIdentifier)
    }
        
    private func setUpcollectionViewDataSource() {
        showLoader(isLoading: true)
        if segmentControl.selectedSegmentIndex == 0 {
            collectionView.dataSource = exhbtsDataSource
            viewModel.getExploreExhbts(reset: true)
            emptyLabel.text = "No Exhbts"
        } else {
            collectionView.dataSource = usersDataSource
            viewModel.getExploreUsers(reset: true)
            emptyLabel.text = "No Users"
        }
        collectionView.collectionViewLayout = createComponsitionalLayout()
    }
    
    private var generateExhbtsDataSource: UICollectionViewDiffableDataSource<ExploreSearchExhbtSection, DisplayModel> {
        let dataSource = UICollectionViewDiffableDataSource<ExploreSearchExhbtSection, DisplayModel>(collectionView: collectionView) { _, indexPath, model in
            guard let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: ExhbtCollectionViewCell.reuseIdentifier, for: indexPath) as? ExhbtCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(model)
            return cell
        }
        return dataSource
    }
    
    private var generateUsersDataSource: UICollectionViewDiffableDataSource<ExploreSearchUserSection, ExploreUserDisplayModel> {
        let dataSource = UICollectionViewDiffableDataSource<ExploreSearchUserSection, ExploreUserDisplayModel>(collectionView: collectionView) { _, indexPath, model in
            guard let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: ExploreSearchCollectionViewCell.reuseIdentifier, for: indexPath) as? ExploreSearchCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(model)
            return cell
        }
        return dataSource
    }
    
    @IBAction func didChangeSegment(_ sender: UISegmentedControl) {
        setUpcollectionViewDataSource()
    }
}

extension ExploreSearchViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if segmentControl.selectedSegmentIndex == 0 {
            viewModel.didSelectExhbtItem(atIndexPath: indexPath)
        } else {
            viewModel.didSelectUserItem(atIndexPath: indexPath)
        }
    }
}

// MARK: - ComponsitionalLayout
extension ExploreSearchViewController {
    
    func createComponsitionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, _ in
            if self.segmentControl.selectedSegmentIndex == 0 {
                return self.createExhbtsSection()
            } else {
                return self.createHorizontalRankSection(hasHeader: false)
            }
        }
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 16
        layout.configuration = config
        return layout
    }
}

extension ExploreSearchViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if ((scrollView.superview?.isKind(of: UICollectionView.self)) != nil) {
            let offsetY = scrollView.contentOffset.y
            let contentHeight = scrollView.contentSize.height
            let scrollViewHeight = scrollView.frame.height
            if offsetY + scrollViewHeight >= contentHeight {
                if segmentControl.selectedSegmentIndex == 0 {
                    viewModel.getExploreExhbts()
                } else {
                    viewModel.getExploreUsers()
                }
            }
        }
    }
}

extension ExploreSearchViewController: Router {}
