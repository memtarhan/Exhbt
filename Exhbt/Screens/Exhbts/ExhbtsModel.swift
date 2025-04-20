//
//  ExhbtsModel.swift
//  Exhbt
//
//  Created by Rakhmatov Bekzod on 25/03/23.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import UIKit

struct ExhbtsModel {
    private let service: ExhbtsServiceProtocol
    private let tagService: TagServiceProtocol

    init(service: ExhbtsServiceProtocol, tagService: TagServiceProtocol) {
        self.service = service
        self.tagService = tagService
    }

    func get(forTag tag: String?, title: String?, page: Int) async throws -> [ExhbtPreviewResponse] {
        try await service.get(forTag: tag, title: title, page: page, limit: 10)
    }

    func getSingle(withId id: Int) async throws -> ExhbtPreviewResponse {
        try await service.getSingle(withId: id)
    }

    func getExploreUser(withKeyword keyword: String, page: Int) async throws -> [ExploreUserResponse] {
        try await service.getUsers(withKeyword: keyword, page: page, limit: 10)
    }

    func getPopularTags() async throws -> [TagResponse] {
        try await tagService.getPopularTags()
    }
}
