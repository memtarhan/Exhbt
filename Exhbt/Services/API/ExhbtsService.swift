//
//  ExploreService.swift
//  Exhbt
//
//  Created by Rakhmatov Bekzod on 28/03/23.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Foundation
import UIKit

protocol ExhbtsServiceProtocol: APIService {
    func get(forTag tag: String?, title: String?, page: Int, limit: Int) async throws -> [ExhbtPreviewResponse]
    func getSingle(withId id: Int) async throws -> ExhbtPreviewResponse
    func getUsers(withKeyword keyword: String, page: Int, limit: Int) async throws -> [ExploreUserResponse]
}

class ExhbtsService: ExhbtsServiceProtocol {
    private var token: String? { UserSettings.shared.token }

    func get(forTag tag: String?, title: String?, page: Int, limit: Int) async throws -> [ExhbtPreviewResponse] {
        guard let url = URL.Exhbts.get(forTag: tag, keyword: title, page: page) else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }
        let response: ExhbtsPreviewResponse = try await handleDataTask(securedSession(withToken: token), from: url)
        return response.items
    }

    func getSingle(withId id: Int) async throws -> ExhbtPreviewResponse {
        guard let url = URL.Exhbts.getSingle(withId: id) else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }
        let response: ExhbtPreviewResponse = try await handleDataTask(securedSession(withToken: token), from: url)
        return response
    }

    func getUsers(withKeyword keyword: String, page: Int, limit: Int) async throws -> [ExploreUserResponse] {
        guard let url = URL.Exhbts.getExploreUser(withKeyword: keyword, page: page, limit: limit) else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }
        let response: ExploreSearchUserResponse = try await handleDataTask(securedSession(withToken: token), from: url)
        return response.items
    }
}
