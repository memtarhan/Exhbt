//
//  StubExhbtService.swift
//  ExhbtTests
//
//  Created by Mehmet Tarhan on 19/03/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

@testable import Exhbt
import Foundation

//class StubExhbtService: ExhbtServiceProtocol {
//    private var token: String? { StubUserSettings.shared.token }
//
//    func createExhbt(withTitle title: String?, category: String) async throws -> ExhbtResponse {
//        guard let url = URL.Exhbts.new() else { throw HTTPError.invalidEndpoint }
//        guard let token else { throw UserError.invalidToken }
//
//        let requestModel = NewExhbtRequest(title: title, category: category)
//        let urlRequest = try requestModel.createURLRequest(withURL: url, encoder: encoder)
//
//        let response: ExhbtResponse = try await handleDataTask(securedSession(withToken: token), for: urlRequest)
//        return response
//    }
//
//    func fetchExhbt(withId id: Int) async throws -> ExhbtResponse {
//        guard let url = URL.Exhbts.single(withId: id) else { throw HTTPError.invalidEndpoint }
//        guard let token else { throw UserError.invalidToken }
//
//        let response: ExhbtResponse = try await handleDataTask(securedSession(withToken: token), from: url)
//        return response
//    }
//
//    func fetchExhbts(atPage page: Int) async throws -> [FeedResponse] {
//        guard let url = URL.Exhbts.ongoing(atPage: page) else { throw HTTPError.invalidEndpoint }
//        guard let token else { throw UserError.invalidToken }
//
//        let response: FeedsResponse = try await handleDataTask(securedSession(withToken: token), from: url)
//        return response.items
//    }
//
//    func fetchArchivedExhbts(atPage page: Int) async throws -> [FeedResponse] {
//        guard let url = URL.Exhbts.archive(atPage: page) else { throw HTTPError.invalidEndpoint }
//        guard let token else { throw UserError.invalidToken }
//
//        let response: FeedsResponse = try await handleDataTask(securedSession(withToken: token), from: url)
//        return response.items
//    }
//}
