//
//  FollowsModel.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 06/09/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Foundation

struct FollowsModel {
    private let meService: MeServiceProtocol
    private let userService: UserServiceProtocol

    init(meService: MeServiceProtocol, userService: UserServiceProtocol) {
        self.meService = meService
        self.userService = userService
    }

    func getFollowers(atPage page: Int) async throws -> FollowersResponse {
        try await meService.getFollowers(atPage: page)
    }

    func getFollowings(atPage page: Int) async throws -> FollowersResponse {
        try await meService.getFollowings(atPage: page)
    }
}
