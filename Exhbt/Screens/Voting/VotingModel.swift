//
//  VotingModel.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 17/05/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Foundation

struct VotingModel {
    private let exhbtService: ExhbtServiceProtocol
    private let competitionService: CompetitionServiceProtocol
    private let meService: MeServiceProtocol

    init(exhbtService: ExhbtServiceProtocol,
         competitionService: CompetitionServiceProtocol,
         meService: MeServiceProtocol) {
        self.exhbtService = exhbtService
        self.competitionService = competitionService
        self.meService = meService
    }

    func getExhbt(withId id: Int) async throws -> ExhbtResponse {
        try await exhbtService.get(withId: id)
    }

    func vote(competitionId: Int) async {
        _ = try? await competitionService.vote(competitionId: competitionId)
    }

    func removeVote(competitionId: Int) async {
        _ = try? await competitionService.removeVote(fromCompetition: competitionId)
    }

    func update(voteStyle style: VoteStyle) async {
        _ = try? await meService.updateDetails(fullName: nil, biography: nil, voteStyle: style)
    }

    func flagExhbt(_ exhbtId: Int) async {
        _ = try? await exhbtService.flag(exhbtId: exhbtId)
    }
}
