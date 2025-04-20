//
//  InviteModel.swift
//  Exhbt
//
//  Created by Adem Tarhan on 7.10.2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Foundation

struct InviteModel {
    private let eventService: EventServiceProtocol
    private let profileService: ProfileServiceProtocol

    init(exhbtService: EventServiceProtocol, profileService: ProfileServiceProtocol) {
        eventService = exhbtService
        self.profileService = profileService
    }

    func invite(invitees: [ContactDisplayModel], eventId: Int) async throws -> EventInvitationsResponse {
        try await eventService.invite(invitees: invitees, eventId: eventId)
    }

    func invite(invitees: [FollowingContactDisplayModel], eventId: Int) async throws -> EventInvitationsResponse {
        try await eventService.invite(invitees: invitees, eventId: eventId)
    }

    func getShareInvitation(forEvent event: Int) async throws -> EventInvitationResponse {
        try await eventService.getShareInvitation(forEvent: event)
    }

    func followings(page: Int) async throws -> [FollowerResponse] {
        try await profileService.getFollowings(atPage: page)
    }
}
