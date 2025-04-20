//
//  AuthService.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 27/07/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import Foundation

protocol AuthServiceProtocol: APIService {
    func signinWithApple(_ identifier: String) async throws -> UserTokenResponse
}

class AuthService: AuthServiceProtocol {
    private let userService: ProfileServiceProtocol

    private var token: String? { UserSettings.shared.token }

    init(userService: ProfileServiceProtocol) {
        self.userService = userService
    }

    func signinWithApple(_ identifier: String) async throws -> UserTokenResponse {
        guard let url = URL.Auth.appleSignIn() else { throw HTTPError.invalidEndpoint }

        let requestModel = SignInWithAppleRequest(identifier: identifier)
        let urlRequest = try requestModel.createURLRequest(withURL: url, encoder: encoder)

        let response: UserTokenResponse = try await handleDataTask(urlSession, for: urlRequest)
        userService.save(token: response.accessToken)
        userService.save(id: response.userId)
        return response
    }
}
