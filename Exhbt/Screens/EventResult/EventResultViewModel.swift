//
//  EventResultViewModel.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 17/12/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Combine
import UIKit

class EventResultViewModel {
    var model: EventResultModel!

    var eventId: Int?

    @Published var winnerPublisher = PassthroughSubject<WinnerModel, Error>()
    @Published var ranksPublisher = PassthroughSubject<([ExhbtResultTopRankUserDisplayModel], [LeaderboardUserDisplayModel]), Never>()
    @Published var titlePublisher = PassthroughSubject<String?, Never>()

    private var response: EventResultResponse?
    
    func load() {
        guard let eventId else { return }

        Task {
            do {
                let response = try await model.getResult(withId: eventId)
                self.response = response
                
                winnerPublisher.send(WinnerModel.from(response: response.data.winner))

                

            } catch {
                debugLog(self, error.localizedDescription)
            }
        }
    }

    func loadResults() {
        guard let response else { return }
        
        let topRanks = createTopRankData(response)
        let bottomRanks = createBottomRankData(response)
        ranksPublisher.send((topRanks, bottomRanks))
        titlePublisher.send(response.data.title)
    }
    
    private func createTopRankData(_ result: EventResultResponse) -> [ExhbtResultTopRankUserDisplayModel] {
        let response = result.data
        let ranks = response.ranks
        let count = ranks.count

        let first = ExhbtResultTopRankUserDisplayModel(userId: ranks[0].userId,
                                                       rankType: .gold,
                                                       photoURL: ranks[0].profilePhoto,
                                                       username: ranks[0].username,
                                                       score: "\(ranks[0].popularity)")

        var data = [first]

        if count > 1 {
            let second = ExhbtResultTopRankUserDisplayModel(userId: ranks[1].userId,
                                                            rankType: .silver,
                                                            photoURL: ranks[1].profilePhoto,
                                                            username: ranks[1].username,
                                                            score: "\(ranks[1].popularity)")
            data.append(second)
        }

        if count > 2 {
            let third = ExhbtResultTopRankUserDisplayModel(userId: ranks[2].userId,
                                                           rankType: .bronze,
                                                           photoURL: ranks[2].profilePhoto,
                                                           username: ranks[2].username,
                                                           score: "\(ranks[2].popularity)")
            data.append(third)
        }

        return data
    }

    private func createBottomRankData(_ result: EventResultResponse) -> [LeaderboardUserDisplayModel] {
        let response = result.data
        let ranks = response.ranks
        let count = ranks.count

        if count > 3 {
            let data = ranks.suffix(from: 3).enumerated().map { index, rankData in
                LeaderboardUserDisplayModel(
                    id: rankData.userId,
                    rankNumber: "\(index + 3)",
                    rankType: .regular,
                    photoURL: rankData.profilePhoto,
                    username: rankData.username,
                    score: "\(rankData.popularity)")
            }

            return data

        } else {
            return []
        }
    }
}
