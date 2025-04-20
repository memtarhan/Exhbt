//
//  StubInvitationService.swift
//  ExhbtTests
//
//  Created by Mehmet Tarhan on 11/04/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

@testable import Exhbt
import Foundation

class StubInvitationService: InvitationServiceProtocol {
    private var token: String? { StubUserSettings.shared.token }

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
