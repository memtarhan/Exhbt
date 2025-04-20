//
//  CompetitionService.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 05/07/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import Photos
import UIKit

protocol CompetitionServiceProtocol: APIService {
    func createCompetition(withAsset asset: CCAsset?, forExhbt exhbtId: Int) async throws
    func vote(competitionId: Int) async throws -> VoteAddResponse
    func removeVote(fromCompetition competitionId: Int) async throws
}

class CompetitionService: CompetitionServiceProtocol {
    private let uploadService: UploadServiceProtocol

    private var token: String? { UserSettings.shared.token }

    init(uploadService: UploadServiceProtocol) {
        self.uploadService = uploadService
    }

    func createCompetition(withAsset asset: CCAsset?, forExhbt exhbtId: Int) async throws {
        guard let url = URL.Competition.create(exhbtId: exhbtId) else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }

        let requestModel = NewCompetitionRequest(exhbtId: exhbtId)
        let urlRequest = try requestModel.createURLRequest(withURL: url, encoder: encoder)

        let response: CompetitionResponse = try await handleDataTask(securedSession(withToken: token), for: urlRequest)

        if let asset = asset {
            _ = try await uploadService.upload(asset: asset, forCompetition: response.id)
        }
    }

    func vote(competitionId: Int) async throws -> VoteAddResponse {
        debugLog(self, "willAddVote competitionId: \(competitionId)")

        guard let url = URL.Competition.vote(competitionId: competitionId) else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }

        let requestModel = VoteAddRequest()
        let urlRequest = try requestModel.createURLRequest(withURL: url, encoder: encoder)

        let (data, response) = try await securedSession(withToken: token).data(for: urlRequest)
        if let httpResponse = response as? HTTPURLResponse {
            debugLog(self, "didAddVote competitionId: \(competitionId) statusCode: \(httpResponse.statusCode)")
        }
        return try decoder.decode(VoteAddResponse.self, from: data)
    }

    func removeVote(fromCompetition competitionId: Int) async throws {
        debugLog(self, "willRemoveVote competitionId: \(competitionId)")

        guard let url = URL.Competition.vote(competitionId: competitionId) else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }

        let requestModel = VoteRemoveRequest()
        let urlRequest = try requestModel.createURLRequest(withURL: url, encoder: encoder, httpMethod: "DELETE")

        let (_, response) = try await securedSession(withToken: token).data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw HTTPError.failed
        }
        if httpResponse.statusCode != 204 { throw HTTPError.failed }
        debugLog(self, "didRemoveVote competitionId: \(competitionId) statusCode: \(httpResponse.statusCode)")
    }
}
