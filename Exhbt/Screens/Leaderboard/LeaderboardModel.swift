//
//  LeaderboardModel.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 28/03/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Foundation

struct LeaderboardModel {
    private let service: LeaderboardServiceProtocol
    private let tagService: TagServiceProtocol

    init(service: LeaderboardServiceProtocol, tagService: TagServiceProtocol) {
        self.service = service
        self.tagService = tagService
    }

    func get(forTag tag: String?, keyword: String?, page: Int, limit: Int) async throws -> [LeaderboardUserResponse] {
        try await service.get(forTag: tag, keyword: keyword, page: page, limit: limit)
    }

    func getPopularTags() async throws -> [TagResponse] {
        try await tagService.getPopularTags()
    }
}
