//
//  TagService.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 12/08/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Foundation
import UIKit

protocol TagServiceProtocol: APIService {
    func getPopularTags() async throws -> [TagResponse]
}

class TagService: TagServiceProtocol {
    private var token: String? { UserSettings.shared.token }

    func getPopularTags() async throws -> [TagResponse] {
        guard let url = URL.Tag.popular() else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }
        let response: TagsResponse = try await handleDataTask(securedSession(withToken: token), from: url)
        return response.items
    }
}
