//
//  PostsService.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 06/12/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Foundation

protocol PostsServiceProtocol: APIService {
    func like(postId id: Int) async throws -> PostResponse
    func dislike(postId id: Int) async throws -> PostResponse
    func delete(post: PostDisplayModel) async throws
}

class PostsService: PostsServiceProtocol {
    private var token: String? { UserSettings.shared.token }

    private let realtimeSync: EventsRealtimeSyncService

    init(realtimeSync: EventsRealtimeSyncService) {
        self.realtimeSync = realtimeSync
    }

    func like(postId id: Int) async throws -> PostResponse {
        guard let url = URL.Post.like(postId: id) else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }

        let requestModel = PostInteractionRequest()
        let urlRequest = try requestModel.createURLRequest(withURL: url, encoder: encoder)

        let response: PostResponse = try await handleDataTask(securedSession(withToken: token), for: urlRequest)
        return response
    }

    func dislike(postId id: Int) async throws -> PostResponse {
        guard let url = URL.Post.dislike(postId: id) else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }

        let requestModel = PostInteractionRequest()
        let urlRequest = try requestModel.createURLRequest(withURL: url, encoder: encoder)

        let response: PostResponse = try await handleDataTask(securedSession(withToken: token), for: urlRequest)
        return response
    }

    func delete(post: PostDisplayModel) async throws {
        guard let url = URL.Post.delete(postId: post.id) else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }

        let requestModel = DeletePostRequest()
        let urlRequest = try requestModel.createURLRequest(withURL: url, encoder: encoder, httpMethod: "DELETE")

        let (_, response) = try await securedSession(withToken: token).data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw HTTPError.failed
        }
        if httpResponse.statusCode != 204 { throw HTTPError.failed }
        debugLog(self, "didDelete postId: \(post.id) statusCode: \(httpResponse.statusCode)")
        realtimeSync.notifyEventUpdateAvailable(eventId: post.eventId)
    }
}
