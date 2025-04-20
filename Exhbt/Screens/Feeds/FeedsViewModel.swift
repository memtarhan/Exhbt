//
//  FeedsViewModel.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 12/06/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import Combine
import UIKit

class FeedsViewModel {
    var model: FeedsModel!

    typealias snapshotType = NSDiffableDataSourceSnapshot<FeedsSection, FeedPreviewDisplayModel>
    private var snapshot = snapshotType()

    @Published var snapshotPublisher = PassthroughSubject<snapshotType, Error>()
    @Published var noMoreExhbts = PassthroughSubject<Bool, Never>()
    @Published var shouldPresentVoting = PassthroughSubject<FeedPreviewDisplayModel, Never>()
    @Published var shouldDisplayEmptyState = PassthroughSubject<Void, Never>()

    private var currentPage = 0

    private var cancellables: Set<AnyCancellable> = []

    init() {
        snapshot.appendSections([.main])
    }

    func didSelectItem(atIndexPath indexPath: IndexPath) {
        let items = snapshot.itemIdentifiers(inSection: .main)
        let index = indexPath.row
        guard index < items.count else { return }
        shouldPresentVoting.send(items[index])
    }

    func load() {
        currentPage += 1
        Task {
            do {
                let feeds = try await model.get(atPage: currentPage)
                let models = feeds.map { FeedPreviewDisplayModel(withResponse: $0) }
                snapshot.appendItems(models, toSection: .main)
                snapshotPublisher.send(snapshot)

                if snapshot.itemIdentifiers(inSection: .main).isEmpty {
                    shouldDisplayEmptyState.send()
                }

            } catch {
                debugLog(self, error)
            }
        }
    }

    func refresh() {
        currentPage = 0
        snapshot.deleteSections(FeedsSection.allCases)
        snapshot.appendSections(FeedsSection.allCases)
        load()
    }

    func willDisplayItem(atIndexPath indexPath: IndexPath) {
        if indexPath.row == snapshot.itemIdentifiers(inSection: .main).count - 1 {
            // Load more
            load()
        }
    }

    // TODO: Fix this according to data updates
    func updateCompetition(atIndex index: Int, voteCount: Int, voted: Bool) {
        let model = snapshot.itemIdentifiers[index]
        model.voted = voted
        model.voteCount = voteCount
        snapshot.reloadItems([model])
        snapshotPublisher.send(snapshot)
    }

    func updateVoteStatus(forItem item: FeedPreviewDisplayModel, count: Int, voted: Bool) {
        let newItem = item
        newItem.voteCount = count
        newItem.voted = voted
        snapshot.reloadItems([newItem])
        snapshotPublisher.send(snapshot)
    }
}
