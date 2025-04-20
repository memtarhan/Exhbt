//
//  ExhbtModel.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 29/08/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import Foundation

class ExhbtModel {
    let exhbtService: ExhbtServiceProtocol

    init(exhbtService: ExhbtServiceProtocol) {
        self.exhbtService = exhbtService
    }

    func fetchExhbt(withId id: Int) async throws -> ExhbtCloudModel {
        let exhbt = try await exhbtService.get(withId: id)
        let competitions = exhbt.competitions.map { competition -> CompetitionModel in
            var mediaDisplayModel: MediaDisplayModel?
            if let media = competition.media {
                mediaDisplayModel = MediaDisplayModel.from(response: media)

            } else {
                mediaDisplayModel = MediaDisplayModel.photoSample
            }
            return CompetitionModel(id: competition.id,
                                    media: mediaDisplayModel!,
                                    votes: competition.votes.map { vote -> CompetitionVoteDisplayModel in
                                        CompetitionVoteDisplayModel(userId: vote.userId,
                                                                    style: VoteStyle(rawValue: vote.styleId) ?? .style1)
                                    })
        }
        let model = ExhbtCloudModel(id: exhbt.id,
                                    tags: exhbt.tags,
                                    createdAt: exhbt.createdDate,
                                    expiresAt: exhbt.expirationDate ?? Date(),
                                    status: exhbt.status,
                                    competitions: competitions)

        return model
    }

    func flagExhbt(_ exhbtId: Int) async {
        _ = try? await exhbtService.flag(exhbtId: exhbtId)
    }
}
