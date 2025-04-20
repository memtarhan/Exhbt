//
//  ExhbtResultViewModel.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 30/05/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Combine
import UIKit

class ExhbtResultViewModel {
    var model: ExhbtResultModel!

    var exhbtId: Int?

    typealias snapshotType = NSDiffableDataSourceSnapshot<ExhbtResultSection, DisplayModel>
    private var snapshot = snapshotType()

    @Published var winnerPublisher = PassthroughSubject<WinnerModel, Error>()
    @Published var snapshotPublisher = PassthroughSubject<snapshotType, Error>()
    @Published var shouldDisplayUser = PassthroughSubject<Int, Never>()
    @Published var shouldDismissResult = PassthroughSubject<Void, Never>()

    private lazy var sections = ExhbtResultSection.allCases

    init() {
        snapshot.appendSections(sections)
    }

    func load() {
        guard let exhbtId else { return }

        Task {
            do {
                let response = try await model.get(withId: exhbtId)

                guard response.canView else {
                    shouldDismissResult.send()
                    return
                }

                let result = response.result
                let data = result.data

                winnerPublisher.send(WinnerModel.from(response: data.winner))

                let preview = ExhbtPreviewDisplayModel(id: result.exhbtId,
                                                       description: data.tags.first ?? "",
                                                       horizontalModels: data.media.map { HorizontalPhotoModel(withResponse: $0) },
                                                       expirationDate: Date(), // TODO: Fix this on backend
                                                       status: .finished,
                                                       isOwn: result.creatorId == UserSettings.shared.id)

                snapshot.appendItems([preview], toSection: .preview)

                let topRankCompetitors = data.topRankCompetitors.enumerated().map { index, value in
                    let rank = RankType(fromId: index) ?? .regular
                    var username = value.username ?? ""
                    if value.id == UserSettings.shared.id {
                        username += "\n(you)"
                    }
                    return ExhbtResultTopRankUserDisplayModel(userId: value.id,
                                                              rankType: rank,
                                                              photoURL: value.profilePhoto,
                                                              username: username,
                                                              score: "\(value.score) points")
                }
                let topRank = ExhbtResultTopRanksDisplayModel(id: result.exhbtId, users: topRankCompetitors)
                snapshot.appendItems([topRank], toSection: .topRank)

                let bottomRank = data.bottomRankCompetitors.map { LeaderboardUserDisplayModel(
                    id: $0.id,
                    rankNumber: "\(0)",
                    rankType: .regular,
                    photoURL: $0.profilePhoto,
                    username: $0.username,
                    score: "\($0.score) points")
                }
                snapshot.appendItems(bottomRank, toSection: .bottomRank)

            } catch {
                debugLog(self, error.localizedDescription)
//                snapshotPublisher.send(completion: .failure(error))
            }
        }
    }

    func loadResults() {
        snapshotPublisher.send(snapshot)
        snapshotPublisher.send(completion: .finished)
    }

    func didSelectUser(withId id: Int) {
        shouldDisplayUser.send(id)
    }

    func didSelectItem(atIndexPath indexPath: IndexPath) {
        guard indexPath.section == 2 else { return }
        // Selected bottom rank user
        let userId = snapshot.itemIdentifiers(inSection: .bottomRank)[indexPath.row].id
        shouldDisplayUser.send(userId)
    }
}
