//
//  VotingViewModel.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 17/05/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Combine
import UIKit

class VotingViewModel {
    var model: VotingModel!
    var exhbtId: Int?

    typealias snapshotType = NSDiffableDataSourceSnapshot<VotingSection, CompetitionDisplayModel>
    private var snapshot = snapshotType()
    lazy var sections = VotingSection.allCases

    @Published var title = PassthroughSubject<String?, Never>()
    @Published var snapshotPublisher = PassthroughSubject<snapshotType, Never>()
    @Published var exhbtVotesCount = PassthroughSubject<Int, Never>()
    @Published var shouldDisplayVoteStyleViewer = PassthroughSubject<Void, Never>()
    @Published var didSelectItem = PassthroughSubject<Int, Never>()

    var currentlyVotedCompetition: CompetitionDisplayModel?

    private var exhbt: ExhbtResponse?
    private var currentPage = 0

    init() {
        snapshot.appendSections(sections)
    }

    func didSelectItem(atIndexPath indexPath: IndexPath) {
        if indexPath.row != currentPage {
            didSelectItem.send(indexPath.row)
            currentPage = indexPath.row
            debugLog(self, "currentPage: \(currentPage)")
        }
    }

    func didSelectItem(atPage page: Int) {
        if page != currentPage {
            didSelectItem.send(page)
            currentPage = page
            debugLog(self, "currentPage: \(currentPage)")
        }
    }

    func load() {
        guard let exhbtId else { return }
        Task {
            do {
                let exhbt = try await model.getExhbt(withId: exhbtId)
                self.exhbt = exhbt
                let fullItems = exhbt.competitions.map {
                    CompetitionDisplayModel(id: $0.id, voted: $0.voted, votes: $0.votes, content: $0.media)
                }
                snapshot.appendItems(fullItems, toSection: .full)
                let thumbnailItems = exhbt.competitions.map {
                    CompetitionDisplayModel(id: $0.id, voted: $0.voted, votes: $0.votes, content: $0.media)
                }
                snapshot.appendItems(thumbnailItems, toSection: .thumbnail)
                snapshotPublisher.send(snapshot)
                didSelectItem.send(0)
            } catch {
                debugLog(self, "Failed to get Exhbt with id: \(exhbtId)")
            }
        }
    }

    func updateVoteStatus(forCompetition competition: CompetitionDisplayModel) {
        guard let exhbt,
              exhbt.canVote else { return }

        currentlyVotedCompetition = competition

        guard UserSettings.shared.voteStyle != nil else {
            shouldDisplayVoteStyleViewer.send()
            return
        }

        let fullItem = competition
        guard let thumbnailItem = snapshot.itemIdentifiers(inSection: .thumbnail).first(where: { $0.id == fullItem.id }) else { return }

        if fullItem.voted {
            // Remove vote
            fullItem.removeVote()
            fullItem.voted = false
            thumbnailItem.voted = false
            debugLog(self, "did vote competition: \(competition.id)")

            Task(priority: .background) {
                await self.model.removeVote(competitionId: fullItem.id)
            }

        } else {
            // Add vote
            fullItem.addVote()
            fullItem.voted = true
            thumbnailItem.voted = true
            debugLog(self, "did remove vote competition: \(competition.id)")

            Task(priority: .background) {
                await self.model.vote(competitionId: fullItem.id)
            }
        }

        snapshot.reloadItems([fullItem, thumbnailItem])
        snapshotPublisher.send(snapshot)

        let competitions = snapshot.itemIdentifiers(inSection: .full)
        let count = competitions.reduce(0) { $0 + $1.votesCount }
        exhbtVotesCount.send(count)
    }

    func update(voteStyle style: VoteStyle) {
        Task(priority: .background) {
            await model.update(voteStyle: style)
        }
    }

    func flag() {
        guard let exhbtId else { return }
        Task {
            await model.flagExhbt(exhbtId)
        }
    }
}
