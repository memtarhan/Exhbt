//
//  FollowListViewModel.swift
//  Exhbt
//
//  Created by Rakhmatov Bekzod on 03/05/23.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Combine
import UIKit

class FollowListViewModel {
    var model: FollowListModel!

    @Published var page = CurrentValueSubject<Int, Never>(-1)
    @Published var snapshot = CurrentValueSubject<snapshotType, Never>(snapshotType())
    @Published var didFinishLoading = PassthroughSubject<Bool, Never>()
    @Published var refreshed = PassthroughSubject<Bool, Never>()

    var shouldShowFollowers = true
    var keyword = ""
    var isFollowing = false
    var userId: Int?
    typealias snapshotType = NSDiffableDataSourceSnapshot<FollowersSection, FollowerDisplayModel>
    private var cancellables: Set<AnyCancellable> = []

    init() {
        snapshot.value.appendSections([.followers])
        page.sink { [weak self] newPage in
            guard let self = self else { return }
            if newPage >= 0 {
                self.fetchFollowers(page: newPage)
            }
        }
        .store(in: &cancellables)
        refreshed.sink { [weak self] _ in
            guard let self = self else { return }
            self.snapshot.value.deleteAllItems()
            self.snapshot.value.appendSections([.followers])
            self.page.send(1)
        }
        .store(in: &cancellables)
    }

    private func fetchFollowers(page: Int) {
        Task {
            var models: [FollowerResponse] = []
            if shouldShowFollowers {
                if keyword.isEmpty {
                    models = try await self.model.followers(withId: userId, page: page)
                } else {
                    models = try await self.model.followersSearch(withId: userId, keyword: keyword, page: page)
                }
            } else {
                if keyword.isEmpty {
                    models = try await self.model.followings(withId: userId, page: page)
                } else {
                    models = try await self.model.followingsSearch(withId: userId, keyword: keyword, page: page)
                }
            }

            if !models.isEmpty {
                let displayModels = self.createDisplayModels(models)
                self.snapshot.value.appendItems(displayModels, toSection: .followers)
                self.snapshot.send(self.snapshot.value)
            }
            didFinishLoading.send(true)
        }
    }

    private func createDisplayModels(_ models: [FollowerResponse]) -> [FollowerDisplayModel] {
        models.map { model in
            FollowerDisplayModel(
                id: model.id,
                username: model.username,
                profilePhoto: model.profilePhoto,
                following: model.following)
        }
    }

    func getSelectedUserId(_ index: Int) -> Int? {
        let users = snapshot.value.itemIdentifiers(inSection: .followers)
        return users[index].id
    }

    func willUpdateFollow(_ user: FollowerDisplayModel) {
        if !snapshot.value.itemIdentifiers(inSection: .followers).isEmpty {
            if let details = snapshot.value.itemIdentifiers(inSection: .followers).first(where: { model in
                model.id == user.id
            }) {
                Task(priority: .background) {
                    if details.followingStatus == .following {
                        try await model.folllowUser(withId: user.id)
                    } else {
                        try await model.unfollowUser(withId: user.id)
                    }
                }
                details.followingStatus.toggle()
                snapshot.value.reloadItems([details])
            }
        }
    }
}
