//
//  Request.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 22/12/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import Foundation

protocol APIRequest: Encodable {
    func createURLRequest(withURL url: URL, encoder: JSONEncoder, httpMethod: String) throws -> URLRequest
    func httpBody(withEncoder encoder: JSONEncoder) throws -> Data
}

extension APIRequest {
    func createURLRequest(withURL url: URL, encoder: JSONEncoder, httpMethod: String = "POST") throws -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let httpBody = try encoder.encode(self)
        request.httpBody = httpBody

        return request
    }

    func httpBody(withEncoder encoder: JSONEncoder) throws -> Data {
        try encoder.encode(self)
    }
}

// MARK: - CompetitorsAddRequest

struct CompetitorsAddRequest: APIRequest {
//    let exhbtId: Int
    let competitors: [NewCompetitorRequest]
}

struct EventJoinersAddRequest: APIRequest {
    let invitees: [NewEventJoinerRequest]
}

// MARK: - FlashInteractRequest

struct FlashInteractRequest: APIRequest {
}

// MARK: - NewCompetitionRequest

struct NewCompetitionRequest: APIRequest {
    let exhbtId: Int
}

// MARK: - NewCompetitionJoinerRequest

struct ExhbtJoinRequest: APIRequest {
    let invitationId: Int?
}

// MARK: - NewCompetitionJoinerRequest

struct NewCompetitionJoinerRequest: APIRequest {}

// MARK: - NewCompetitorRequest

struct NewCompetitorRequest: APIRequest {
    let exhbtUserId: Int?
    let phoneNumber: String?
}

// MARK: - NewExhbtRequest

struct NewExhbtRequest: APIRequest {
    let tags: [String]
    let exhbtType: ExhbtTypeRequest
    let description: String
}

struct NewEventJoinerRequest: APIRequest {
    let eventUserId: Int?
    let phoneNumber: String?
}

enum ExhbtTypeRequest: String, APIRequest {
    case `public`
    case `private`
}

// MARK: - NewEventRequest

struct NewEventRequest: APIRequest {
    let title: String
    let description: String
    let durationInDays: Int
    let nsfw: Bool
    let eventType: EventTypeRequest
    let fullAddress: String
    let longitude: Double
    let latitude: Double
}

// MARK: - EventJoinerRequest

struct EventJoinerRequest: APIRequest {}

// MARK: - EventPostRequest

struct EventPostRequest: APIRequest {}

// MARK: - EventTypeRequest

enum EventTypeRequest: String, APIRequest {
    case `public`
    case `private`
}

// MARK: - ExhbtFlagRequest

struct ExhbtFlagRequest: APIRequest {}

// MARK: - InvitationRequest

struct InvitationRequest: APIRequest { }

// MARK: - SharableExhbtLinkRequest

struct SharableExhbtLinkRequest: APIRequest {
    let link: String
}

struct SignInWithAppleRequest: APIRequest {
    let identifier: String
}

// MARK: - VoteStyleRequest

struct VoteStyleRequest: APIRequest {
    let id: Int
}

struct ProfileUpdateRequest: APIRequest {
    let fullName: String?
    let biography: String?
    let voteStyleId: Int?
}

struct UsernameUpdateRequest: APIRequest {
    let username: String?
}

struct NotificationsDeviceTokenRequest: APIRequest {
    let token: String?
}

struct NotificationsReadRequest: APIRequest {
}

// MARK: - VoteAddRequest

struct VoteAddRequest: APIRequest { }

// MARK: - VoteRemoveRequest

struct VoteRemoveRequest: APIRequest { }

// MARK: - FollowRequest

struct FollowRequest: APIRequest {}

// MARK: - UnfollowRequest

struct UnfollowRequest: APIRequest {}

// MARK: - DeleteExhbtRequest

struct DeleteExhbtRequest: APIRequest {
    let exhbtId: Int
}

// MARK: - DeleteAccountRequest

struct DeleteAccountRequest: APIRequest {
}

struct PostInteractionRequest: APIRequest {}

struct DeletePostRequest: APIRequest {
}
