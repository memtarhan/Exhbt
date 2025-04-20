//
//  SigninModel.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 19/07/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import Foundation

class SigninModel {
    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    func signin(withIdentifier identifier: String) async throws -> UserTokenResponse {
        try await authService.signinWithApple(identifier)
    }
}
