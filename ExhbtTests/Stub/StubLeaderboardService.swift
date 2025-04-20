//
//  StubLeaderboardService.swift
//  ExhbtTests
//
//  Created by Mehmet Tarhan on 28/03/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

@testable import Exhbt
import Foundation

class StubLeaderboardService: LeaderboardServiceProtocol {
    private var token: String? { StubUserSettings.shared.token }

    func get(forCategory category: String, page: Int, limit: Int) async throws -> [LeaderboardUserResponse] {
        guard let url = URL.Leaderboard.get(forCategory: category, page: page, limit: limit) else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }

        let response: LeaderboardResponse = try await handleDataTask(securedSession(withToken: token), from: url)
        return response.items
    }
}
