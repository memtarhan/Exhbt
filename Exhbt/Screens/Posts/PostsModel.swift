//
//  PostsModel.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 03/12/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Foundation

class PostsModel {
    private let service: PostsServiceProtocol
    private let eventService: EventServiceProtocol

    init(service: PostsServiceProtocol, eventService: EventServiceProtocol) {
        self.service = service
        self.eventService = eventService
    }

    func getEventDetails(forEvent eventId: Int) async throws -> EventResponse {
        try await eventService.getSingle(withId: eventId)
    }

    func get(forEvent eventId: Int, page: Int) async throws -> [PostResponse] {
        try await eventService.getPosts(forEvent: eventId, page: page)
    }

    func post(eventId: Int, asset: CCAsset, task: URLSessionTaskDelegate? = nil) async throws -> PostResponse {
        try await eventService.post(eventId: eventId, asset: asset, task: task)
    }

    func like(postId id: Int) async throws -> PostResponse {
        try await service.like(postId: id)
    }

    func dislike(postId id: Int) async throws -> PostResponse {
        try await service.dislike(postId: id)
    }

    func delete(post: PostDisplayModel) async throws {
        try await service.delete(post: post)
    }
}
