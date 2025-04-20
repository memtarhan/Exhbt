//
//  StubExhbtDetailsService.swift
//  ExhbtTests
//
//  Created by Mehmet Tarhan on 05/04/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

@testable import Exhbt
import Foundation

class StubExhbtDetailsService: ExhbtDetailsServiceProtocol {
    private var token: String? { StubUserSettings.shared.token }

    func getExhbt(withId id: Int) async throws -> ExhbtDetailsResponse {
        guard let url = URL.Exhbt.details(exhbtId: id) else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }

        let response: ExhbtDetailsResponse = try await handleDataTask(securedSession(withToken: token), from: url)
        return response
    }
}
