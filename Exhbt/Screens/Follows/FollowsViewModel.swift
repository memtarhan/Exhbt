//
//  FollowsViewModel.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 06/09/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Combine
import UIKit

class FollowsViewModel {
    var model: FollowsModel!

    typealias snapshotType = NSDiffableDataSourceSnapshot<FollowsSection, DisplayModel>
    private var snapshot = snapshotType()

    @Published var snapshotPublisher = PassthroughSubject<snapshotType, Error>()

    private var followersCount = 0
    private var followingsCount = 0

    // TODO: Format it if necessary
    var segmentedControlTitles: [String] {
        ["\(followersCount) Followers", "\(followingsCount) Followings"]
    }

    private var currentPage = 0

    init() {
        snapshot.appendSections([.followers, .followings])
    }

    func loadFollowers(forUser userId: Int?) {
        currentPage += 1

        if let userId {
        } else {
            /// Me
            Task {
                do {
                    let response = try await model.getFollowers(atPage: currentPage)
                    followersCount = response.followersCount
                    followingsCount = response.followingsCount
                    let users = response.items.map { FollowDisplayModel.from(response: $0) }
                    snapshot.appendItems(users, toSection: .followers)
                    snapshotPublisher.send(snapshot)

                } catch {
                    debugLog(self, "failed to load followers")
                }
            }
        }
    }

    func didSelectItem(atIndexPath indexPath: IndexPath) {}
    func willDisplayItem(atIndexPath indexPath: IndexPath) {}
}
