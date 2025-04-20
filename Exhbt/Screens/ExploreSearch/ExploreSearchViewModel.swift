//
//  ExploreSearchViewModel.swift
//  Exhbt
//
//  Created by Bekzod Rakhmatov on 17/06/23.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Combine
import UIKit

class ExploreSearchViewModel {
    var model: ExhbtsModel!
    var searchQuery: String!
    var category: Category!

    private var page = 0

    typealias exhbtsSnapshotType = NSDiffableDataSourceSnapshot<ExploreSearchExhbtSection, DisplayModel>
    var exhbtsSnapshot = exhbtsSnapshotType()
    typealias usersSnapshotType = NSDiffableDataSourceSnapshot<ExploreSearchUserSection, ExploreUserDisplayModel>
    var usersSnapshot = usersSnapshotType()

    @Published var exhbtsSnapshotPublisher = PassthroughSubject<exhbtsSnapshotType, Error>()
    @Published var usersSnapshotPublisher = PassthroughSubject<usersSnapshotType, Error>()
    @Published var shouldNavigateToDetails = PassthroughSubject<ExhbtPreviewDisplayModel, Never>()
    @Published var willDisplayUser = PassthroughSubject<Int, Never>()

    init() {
        exhbtsSnapshot.appendSections([ExploreSearchExhbtSection.exhbts])
        usersSnapshot.appendSections([ExploreSearchUserSection.users])
    }

    func getExploreExhbts(reset: Bool = false) {
        if reset {
            page = 1
            exhbtsSnapshot.deleteAllItems()
            exhbtsSnapshot.appendSections([ExploreSearchExhbtSection.exhbts])
        } else {
            page += 1
        }
        Task {
            do {
                // TODO: Check this to see if needed
                let models = try await model.get(forTag: nil, title: searchQuery, page: page)
                let displayModels = createDisplayModels(models)
                exhbtsSnapshot.appendItems(displayModels, toSection: .exhbts)
                exhbtsSnapshotPublisher.send(exhbtsSnapshot)
            } catch {
                exhbtsSnapshotPublisher.send(completion: .failure(error))
            }
        }
    }

    func getExploreUsers(reset: Bool = false) {
        if reset {
            page = 1
            usersSnapshot.deleteAllItems()
            usersSnapshot.appendSections([ExploreSearchUserSection.users])
        } else {
            page += 1
        }
        Task {
            do {
                let models = try await model.getExploreUser(withKeyword: searchQuery, page: page)
                let displayModels = createExploreUserDisplayModels(models)
                usersSnapshot.appendItems(displayModels, toSection: .users)
                usersSnapshotPublisher.send(usersSnapshot)
            } catch {
                usersSnapshotPublisher.send(completion: .failure(error))
            }
        }
    }

    func didSelectUserItem(atIndexPath indexPath: IndexPath) {
        let users = usersSnapshot.itemIdentifiers(inSection: .users)
        if users.count > indexPath.row {
            let user = users[indexPath.row]
            willDisplayUser.send(user.id)
        }
    }

    func didSelectExhbtItem(atIndexPath indexPath: IndexPath) {
        let exhbts = exhbtsSnapshot.itemIdentifiers(inSection: .exhbts)
        if exhbts.count > indexPath.row {
            if let exhbt = exhbts[indexPath.row] as? ExhbtPreviewDisplayModel {
                shouldNavigateToDetails.send(exhbt)
            }
        }
    }
}

private extension ExploreSearchViewModel {
    func createDisplayModels(_ models: [ExhbtPreviewResponse]) -> [ExhbtPreviewDisplayModel] {
        models.map {
            ExhbtPreviewDisplayModel(
                id: $0.id,
                description: $0.tags.first ?? "",
                horizontalModels: $0.media.map { HorizontalPhotoModel(withResponse: $0) },
                expirationDate: $0.dates.expirationDate ?? $0.dates.startDate,
                status: ExhbtStatus(fromType: $0.status),
                isOwn: $0.isOwn)
        }
    }

    func createExploreUserDisplayModels(_ models: [ExploreUserResponse]) -> [ExploreUserDisplayModel] {
        models.map {
            ExploreUserDisplayModel(
                id: $0.id,
                username: $0.username,
                fullName: $0.fullName,
                profilePhoto: $0.profilePhoto)
        }
    }
}
