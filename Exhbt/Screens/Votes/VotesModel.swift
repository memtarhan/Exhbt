//
//  VotesModel.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 20/05/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Foundation

struct VotesModel {
    private let service: MeServiceProtocol
    private let userService: UserServiceProtocol

    init(service: MeServiceProtocol, userService: UserServiceProtocol) {
        self.service = service
        self.userService = userService
    }

    func get(forUser user: Int? = nil) async throws -> [FeedPreviewResponse] {
        if let user {
            return try await userService.getVotedExhbts(withId: user)
        }
        return try await service.getVotedExhbts()
    }
}
