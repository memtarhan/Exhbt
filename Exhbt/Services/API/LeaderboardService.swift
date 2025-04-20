//
//  LeaderboardService.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 28/03/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Foundation

protocol LeaderboardServiceProtocol: APIService {
    func get(forTag tag: String?, keyword: String?, page: Int, limit: Int) async throws -> [LeaderboardUserResponse]
}

class LeaderboardService: LeaderboardServiceProtocol {
    private var token: String? { UserSettings.shared.token }

    func get(forTag tag: String?, keyword: String?, page: Int, limit: Int) async throws -> [LeaderboardUserResponse] {
        guard let url = URL.Leaderboard.get(forTag: tag, keyword: keyword, page: page, limit: limit) else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }

        let response: LeaderboardResponse = try await handleDataTask(securedSession(withToken: token), from: url)
        return response.items
    }
}
