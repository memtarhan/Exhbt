//
//  InvitationService.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 10/04/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Foundation

protocol InvitationServiceProtocol: APIService {
    func getInvitation(withId id: Int) async throws -> InvitationResponse
    func acceptInvitation(withId id: Int) async throws -> InvitationResponse
}

class InvitationService: InvitationServiceProtocol {
    private var token: String? { UserSettings.shared.token }

    func getInvitation(withId id: Int) async throws -> InvitationResponse {
        guard let url = URL.Invitation.get(withId: id) else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }

        let response: InvitationResponse = try await handleDataTask(securedSession(withToken: token), from: url)
        return response
    }

    func acceptInvitation(withId id: Int) async throws -> InvitationResponse {
        guard let url = URL.Invitation.accept(withId: id) else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }

        let requestModel = InvitationRequest()
        let urlRequest = try requestModel.createURLRequest(withURL: url, encoder: encoder)

        let response: InvitationResponse = try await handleDataTask(securedSession(withToken: token), for: urlRequest)
        return response
    }
}
