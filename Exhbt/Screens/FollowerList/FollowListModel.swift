//
//  FollowListModel.swift
//  Exhbt
//
//  Created by Rakhmatov Bekzod on 03/05/23.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import UIKit

class FollowListModel {
    let profileService: ProfileServiceProtocol
    let userService: UserServiceProtocol
    let meService: MeServiceProtocol

    init(profileService: ProfileServiceProtocol, userService: UserServiceProtocol, meService: MeServiceProtocol) {
        self.profileService = profileService
        self.userService = userService
        self.meService = meService
    }

    func followers(withId id: Int?, page: Int) async throws -> [FollowerResponse] {
        if let id = id {
            return try await userService.followers(withId: id, page: page)
        } else {
            return try await meService.getFollowers(atPage: page).items
        }
    }

    func followings(withId id: Int?, page: Int) async throws -> [FollowerResponse] {
        if let id = id {
            return try await userService.followings(withId: id, page: page)
        } else {
            return try await meService.getFollowings(atPage: page).items
        }
    }

    func followersSearch(withId id: Int?, keyword: String, page: Int) async throws -> [FollowerResponse] {
        if let id = id {
            return try await userService.followersSearch(withId: id, keyword: keyword, page: page)
        } else {
            return try await meService.searchFollowers(withKeyword: keyword, page: page)
        }
    }

    func followingsSearch(withId id: Int?, keyword: String, page: Int) async throws -> [FollowerResponse] {
        if let id = id {
            return try await userService.followingsSearch(withId: id, keyword: keyword, page: page)
        } else {
            return try await meService.searchFollowings(withKeyword: keyword, page: page)
        }
    }

    func folllowUser(withId id: Int) async throws {
        try await meService.follow(withId: id)
    }

    func unfollowUser(withId id: Int) async throws {
        try await meService.unfollow(withId: id)
    }
}

enum FollowersSection: CaseIterable {
    case followers
}
