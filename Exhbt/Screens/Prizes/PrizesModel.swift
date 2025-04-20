//
//  PrizesModel.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 16/01/2024.
//  Copyright © 2024 Exhbt LLC. All rights reserved.
//

import Foundation

struct PrizesModel {
    private let meService: MeServiceProtocol
    private let userService: UserServiceProtocol

    init(meService: MeServiceProtocol, userService: UserServiceProtocol) {
        self.meService = meService
        self.userService = userService
    }

    func getPrizes(forUserId userId: Int?) async throws -> [PrizeResponse] {
        if let userId {
            return try await userService.getPrizes(withId: userId)

        } else {
            return try await meService.getPrizes()
        }
    }
}
