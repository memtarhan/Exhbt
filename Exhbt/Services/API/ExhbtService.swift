//
//  ExhbtService.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 24/07/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import Photos
import UIKit

protocol ExhbtServiceProtocol: APIService {
    func get(withId id: Int) async throws -> ExhbtResponse
    func create(tags: [String], description: String, exhbtType: ExhbtType) async throws -> ExhbtResponse
    func delete(withId id: Int) async throws

    func getDetails(withId id: Int) async throws -> ExhbtDetailsResponse
    func getResult(withId id: Int) async throws -> ExhbtResultWholeResponse

    func join(exhbtId: Int, withInvitationId invitationId: Int?, withAsset asset: CCAsset?) async throws

    func flag(exhbtId: Int) async throws -> ExhbtFlagResponse

    // TODO: Optimize it, duplicated code here
    func addCompetitors(competitors: [ContactDisplayModel], exhbtId: Int) async throws -> InvitationsResponse
    func addCompetitors(competitors: [FollowingContactDisplayModel], exhbtId: Int) async throws -> InvitationsResponse

    func getShareInvitation(forExhbt exhbt: Int) async throws -> InvitationResponse

    func checkEligibility() async throws
}

class ExhbtService: ExhbtServiceProtocol {
    private let uploadService: UploadServiceProtocol
    private let meService: MeServiceProtocol

    private var token: String? { UserSettings.shared.token }

    init(uploadService: UploadServiceProtocol, meService: MeServiceProtocol) {
        self.uploadService = uploadService
        self.meService = meService
    }

    func get(withId id: Int) async throws -> ExhbtResponse {
        guard let url = URL.Exhbt.get(exhbtId: id) else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }

        let response: ExhbtResponse = try await handleDataTask(securedSession(withToken: token), from: url)
        return response
    }

    func create(tags: [String], description: String, exhbtType: ExhbtType) async throws -> ExhbtResponse {
        guard let url = URL.Exhbt.create() else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }

        let typeRequest = ExhbtTypeRequest(rawValue: exhbtType.rawValue)!
        let requestModel = NewExhbtRequest(tags: tags, exhbtType: typeRequest, description: description)
        let urlRequest = try requestModel.createURLRequest(withURL: url, encoder: encoder)

        let response: NewExhbtResponse = try await handleDataTask(securedSession(withToken: token), for: urlRequest)
        UserSettings.shared.coinsCount = response.coinsCount
        return response.exhbt
    }

    func delete(withId id: Int) async throws {
        guard let url = URL.Exhbt.delete(exhbtId: id) else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }

        let requestModel = DeleteExhbtRequest(exhbtId: id)
        let urlRequest = try requestModel.createURLRequest(withURL: url, encoder: encoder, httpMethod: "DELETE")

        let (_, response) = try await securedSession(withToken: token).data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw HTTPError.failed
        }
        if httpResponse.statusCode != 204 { throw HTTPError.failed }
        debugLog(self, "didDelete exhbtId: \(id) statusCode: \(httpResponse.statusCode)")
    }

    func getDetails(withId id: Int) async throws -> ExhbtDetailsResponse {
        guard let url = URL.Exhbt.details(exhbtId: id) else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }

        let response: ExhbtDetailsResponse = try await handleDataTask(securedSession(withToken: token), from: url)
        return response
    }

    func getResult(withId id: Int) async throws -> ExhbtResultWholeResponse {
        guard let url = URL.Exhbt.result(exhbtId: id) else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }

        let response: ExhbtResultWholeResponse = try await handleDataTask(securedSession(withToken: token), from: url)
        return response
    }

    func join(exhbtId: Int, withInvitationId invitationId: Int?, withAsset asset: CCAsset?) async throws {
        _ = try await checkEligibility()

        guard let url = URL.Exhbt.join(exhbtId: exhbtId) else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }

        let requestModel = ExhbtJoinRequest(invitationId: invitationId)
        let urlRequest = try requestModel.createURLRequest(withURL: url, encoder: encoder)

        let response: NewCompetitionResponse = try await handleDataTask(securedSession(withToken: token), for: urlRequest)
        UserSettings.shared.coinsCount = response.coinsCount

        if let asset = asset {
            _ = try await uploadService.upload(asset: asset, forCompetition: response.competition.id)
        }
    }

    func flag(exhbtId: Int) async throws -> ExhbtFlagResponse {
        guard let url = URL.Exhbt.flag(exhbtId: exhbtId) else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }

        let requestModel = ExhbtFlagRequest()
        let urlRequest = try requestModel.createURLRequest(withURL: url, encoder: encoder)

        let response: ExhbtFlagResponse = try await handleDataTask(securedSession(withToken: token), for: urlRequest)
        return response
    }

    func addCompetitors(competitors: [ContactDisplayModel], exhbtId: Int) async throws -> InvitationsResponse {
        guard let url = URL.Exhbt.addCompetitors(exhbtId: exhbtId) else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }

        let newCompetitorRequests = competitors
            .map { NewCompetitorRequest(exhbtUserId: nil, phoneNumber: $0.phoneNumber) }

        let requestModel = CompetitorsAddRequest(competitors: newCompetitorRequests)
        let urlRequest = try requestModel.createURLRequest(withURL: url, encoder: encoder)

        let response: InvitationsResponse = try await handleDataTask(securedSession(withToken: token), for: urlRequest)
        return response
    }

    func addCompetitors(competitors: [FollowingContactDisplayModel], exhbtId: Int) async throws -> InvitationsResponse {
        guard let url = URL.Exhbt.addCompetitors(exhbtId: exhbtId) else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }

        let newCompetitorRequests = competitors
            .map { NewCompetitorRequest(exhbtUserId: $0.userId, phoneNumber: nil) }

        let requestModel = CompetitorsAddRequest(competitors: newCompetitorRequests)
        let urlRequest = try requestModel.createURLRequest(withURL: url, encoder: encoder)

        let response: InvitationsResponse = try await handleDataTask(securedSession(withToken: token), for: urlRequest)
        return response
    }

    func getShareInvitation(forExhbt exhbt: Int) async throws -> InvitationResponse {
        guard let url = URL.Exhbt.shareInvitation(exhbtId: exhbt) else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }

        let response: InvitationResponse = try await handleDataTask(securedSession(withToken: token), from: url)
        return response
    }

    func checkEligibility() async throws {
        let elgibibilityResponse = try await meService.getEligibility()
        guard elgibibilityResponse.eligibleToCreateExhbt else { throw UserError.inEligible }
    }
}
