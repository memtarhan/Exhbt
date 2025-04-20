//
//  FlashService.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 21/06/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Foundation

protocol FlashServiceProtocol: APIService {
    func get(atPage page: Int) async throws -> (items: [FlashPreviewResponse], coinsCount: Int)
    func interact(withCompetition competition: Int, interaction: InteractionResponse) async throws -> FlashInteractResponse
}

class FlashService: FlashServiceProtocol {
    private var token: String? { UserSettings.shared.token }

    func get(atPage page: Int) async throws -> (items: [FlashPreviewResponse], coinsCount: Int) {
        guard let url = URL.Flash.get(atPage: page) else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }

        let response: FlashPreviewsResponse = try await handleDataTask(securedSession(withToken: token), from: url)
        return (response.items, response.coinsCount)
    }

    func interact(withCompetition competition: Int, interaction: InteractionResponse) async throws -> FlashInteractResponse {
        let url: URL?
        switch interaction {
        case .like:
            url = URL.Flash.like(competitionId: competition)
        case .dislike:
            url = URL.Flash.dislike(competitionId: competition)
        }
        guard let url else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }

        let requestModel = FlashInteractRequest()
        let urlRequest = try requestModel.createURLRequest(withURL: url, encoder: encoder)

        let response: FlashInteractResponse = try await handleDataTask(securedSession(withToken: token), for: urlRequest)
        UserSettings.shared.coinsCount = response.coinsCount
        return response
    }
}
