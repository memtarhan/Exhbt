//
//  StubFeedService.swift
//  ExhbtTests
//
//  Created by Mehmet Tarhan on 17/03/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Foundation
@testable import Exhbt 

class StubFeedService: FeedsServiceProtocol {
    private var token: String? { StubUserSettings.shared.token }
    
    func getFeeds(atPage page: Int) async throws -> [FeedResponse] {
        guard let url = URL.Feeds.get(atPage: page) else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }

        let response: FeedsResponse = try await handleDataTask(securedSession(withToken: token), from: url)
        return response.items
    }
}
