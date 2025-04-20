//
//  StubUserService.swift
//  ExhbtTests
//
//  Created by Mehmet Tarhan on 29/03/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

@testable import Exhbt
import Foundation

class StubUserService: UserServiceProtocol {
    
    private var token: String? { StubUserSettings.shared.token }

    func getProfileDetails(withId id: Int) async throws -> UserResponse {
        guard let url = URL.User.get(withId: id) else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }

        let response: UserResponse = try await handleDataTask(securedSession(withToken: token), from: url)
        UserSettings.shared.save(response: response)
        return response
    }
    
    func getCreatedExhbts(withId id: Int, atPage page: Int) async throws -> [FeedResponse] {
        []
    }
    
    func getParticipatedExhbts(withId id: Int, atPage page: Int) async throws -> [FeedResponse] {
        []
    }
}
