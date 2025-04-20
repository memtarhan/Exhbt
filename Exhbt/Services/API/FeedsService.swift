//
//  FeedsService.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 24/07/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import Foundation

protocol FeedsServiceProtocol: APIService {
    func get(atPage page: Int) async throws -> [FeedPreviewResponse]
}

class FeedsService: FeedsServiceProtocol {
    private var token: String? { UserSettings.shared.token }

    func get(atPage page: Int) async throws -> [FeedPreviewResponse] {
        guard let url = URL.Feeds.get(atPage: page) else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }

        let response: FeedsPreviewResponse = try await handleDataTask(securedSession(withToken: token), from: url)
        return response.items
    }
}
