//
//  SplashModel.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 17/11/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Foundation

class SplashModel {
    private let meService: MeServiceProtocol

    init(meService: MeServiceProtocol) {
        self.meService = meService
    }

    func fetchProfileData() async throws -> UserResponse {
        _ = try await meService.getEligibility()
        return try await meService.getDetails()
    }
}
