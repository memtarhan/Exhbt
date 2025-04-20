//
//  ChooseCompetitorsModel.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 08/10/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import UIKit

struct ChooseCompetitorsModel {
    private let exhbtService: ExhbtServiceProtocol
    private let profileService: ProfileServiceProtocol

    init(exhbtService: ExhbtServiceProtocol, profileService: ProfileServiceProtocol) {
        self.exhbtService = exhbtService
        self.profileService = profileService
    }

    func invite(competitors: [ContactDisplayModel], exhbtId: Int) async throws -> InvitationsResponse {
        return try await exhbtService.addCompetitors(competitors: competitors, exhbtId: exhbtId)
    }
    
    func invite(competitors: [FollowingContactDisplayModel], exhbtId: Int) async throws -> InvitationsResponse {
        return try await exhbtService.addCompetitors(competitors: competitors, exhbtId: exhbtId)
    }

    func getShareInvitation(forExhbt exhbt: Int) async throws -> InvitationResponse {
        return try await exhbtService.getShareInvitation(forExhbt: exhbt)
    }

    func followings(page: Int) async throws -> [FollowerResponse] {
        return try await profileService.getFollowings(atPage: page)
    }
}
