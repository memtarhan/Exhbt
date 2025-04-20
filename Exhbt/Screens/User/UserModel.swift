//
//  UserModel.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 13/05/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Foundation

struct UserModel {
    private let userService: UserServiceProtocol
    private let meService: MeServiceProtocol

    init(userService: UserServiceProtocol, meService: MeServiceProtocol) {
        self.userService = userService
        self.meService = meService
    }

    func getDetails(withId id: Int) async throws -> ProfileDetailsDisplayModel {
        let response = try await userService.getDetails(withId: id)
        let tags = try await userService.getTags(withId: id)
        return ProfileDetailsDisplayModel.from(response: response, tags: tags)
    }

    func getGallery(withId id: Int, atPage page: Int) async throws -> [GalleryDisplayModel] {
        let response = try await userService.getSubmissions(withId: id, atPage: page)
        return response.map { GalleryDisplayModel.from(response: $0) }
    }

    func getPublicExhbts(withId id: Int, atPage page: Int) async throws -> [ExhbtPreviewDisplayModel] {
        let response = try await userService.getPublicExhbts(withId: id, atPage: page)
        return response.map { ExhbtPreviewDisplayModel.from(response: $0) }
    }

    func getEvents(withId id: Int, atPage page: Int) async throws -> [EventDisplayModel] {
        let response = try await userService.getEvents(withId: id, atPage: page)
        return response.map { EventDisplayModel.from(response: $0) }
    }

    func folllowUser(withId id: Int) async throws {
        try await meService.follow(withId: id)
    }

    func unfollowUser(withId id: Int) async throws {
        try await meService.unfollow(withId: id)
    }
}
