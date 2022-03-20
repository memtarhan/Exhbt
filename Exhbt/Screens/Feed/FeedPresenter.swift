//
//  FeedPresenter.swift
//  Exhbt
//
//  Created Mehmet Tarhan on 03/03/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import Combine
import UIKit

protocol FeedPresenter: AnyObject {
    var view: FeedViewController? { get set }
    var interactor: FeedInteractor? { get set }
    var router: FeedRouter? { get set }

    var triggerPublisher: Published<Bool>.Publisher { get }
    var fetchCompletionPublisher: Published<Bool>.Publisher { get }
    var diffableDataSource: FeedsTableViewDiffableDataSource? { get set }

    func presentDetails()
}

class FeedPresenterImpl: FeedPresenter {
    var view: FeedViewController?
    var interactor: FeedInteractor?
    var router: FeedRouter?

    private var cancellables: Set<AnyCancellable> = []
    @Published var trigger: Bool = false
    var triggerPublisher: Published<Bool>.Publisher { $trigger }

    @Published var fetched: Bool = false
    var fetchCompletionPublisher: Published<Bool>.Publisher { $fetched }
    var diffableDataSource: FeedsTableViewDiffableDataSource?
    var snapshot = NSDiffableDataSourceSnapshot<String?, FeedEntity.Feed.ViewModel>()

    init() {
        triggerPublisher.receive(on: RunLoop.main).debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { _ in
                self.fetchFeeds()
            }.store(in: &cancellables)

        fetchCompletionPublisher.receive(on: RunLoop.main).debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { _ in
            }.store(in: &cancellables)
    }

    func presentDetails() {
        router?.navigateToDetails()
    }

    private func fetchFeeds() {
        // TODO: Actually feetch feeds from backend
        fetched = true
        snapshot.deleteAllItems()
        snapshot.appendSections([""])

        var feeds = [FeedResponse]()

        for i in 0 ..< 20 {
            feeds.append(FeedResponse(id: "id=\(i)"))
        }

        if feeds.isEmpty {
            diffableDataSource?.apply(snapshot, animatingDifferences: true)
            return
        }

        let viewModels = feeds.map { repo -> FeedEntity.Feed.ViewModel in
            let random = Int.random(in: 3 ... 6)

            var images = [String]()
            (0 ... random).forEach { _ in
                let index = Int.random(in: 1 ... 11)
                images.append("image (\(index))")
            }
            return FeedEntity.Feed.ViewModel(id: repo.id,
                                             images: images,
                                             voted: random % 2 == 0,
                                             voteCount: random * 4)
        }
        snapshot.appendItems(viewModels, toSection: "")
        diffableDataSource?.apply(snapshot, animatingDifferences: true)
    }
}

struct FeedResponse: Codable {
    var id: String!
}
