//
//  UserService.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 29/03/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Foundation

protocol UserServiceProtocol: APIService {
    func getDetails(withId id: Int) async throws -> UserResponse
    func getSubmissions(withId id: Int, atPage page: Int) async throws -> [UserSubmissionResponse]
    func getPublicExhbts(withId id: Int, atPage page: Int) async throws -> [ExhbtPreviewResponse]
    func getVotedExhbts(withId id: Int) async throws -> [FeedPreviewResponse]
    func getEvents(withId id: Int, atPage page: Int) async throws -> [EventResponse]
    func getTags(withId id: Int) async throws -> [UserTagResponse]
    func getPrizes(withId id: Int) async throws -> [PrizeResponse]

    // TODO: Check if below is needed
    func getProfileDetails(withId id: Int) async throws -> UserResponse
    func getCreatedExhbts(withId id: Int, atPage page: Int) async throws -> [FeedResponse]
    func getParticipatedExhbts(withId id: Int, atPage page: Int) async throws -> [FeedResponse]
    func followers(withId id: Int, page: Int) async throws -> [FollowerResponse]
    func followings(withId id: Int, page: Int) async throws -> [FollowerResponse]
    func followersSearch(withId id: Int, keyword: String, page: Int) async throws -> [FollowerResponse]
    func followingsSearch(withId id: Int, keyword: String, page: Int) async throws -> [FollowerResponse]
}

class UserService: UserServiceProtocol {
    private var token: String? { UserSettings.shared.token }

    func getDetails(withId id: Int) async throws -> UserResponse {
        guard let url = URL.User.get(withId: id) else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }

        let response: UserResponse = try await handleDataTask(securedSession(withToken: token), from: url)
        return response
    }

    func getSubmissions(withId id: Int, atPage page: Int) async throws -> [UserSubmissionResponse] {
        guard let url = URL.User.submissions(withId: id, atPage: page) else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }

        let response: UserSubmissionsResponse = try await handleDataTask(securedSession(withToken: token), from: url)
        return response.items
    }

    func getPublicExhbts(withId id: Int, atPage page: Int) async throws -> [ExhbtPreviewResponse] {
        guard let url = URL.User.publicExhbts(withId: id, atPage: page) else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }

        let response: ExhbtsPreviewResponse = try await handleDataTask(securedSession(withToken: token), from: url)
        return response.items
    }

    func getVotedExhbts(withId id: Int) async throws -> [FeedPreviewResponse] {
        guard let url = URL.User.votedExhbts(withId: id) else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }

        let response: FeedsPreviewResponse = try await handleDataTask(securedSession(withToken: token), from: url)
        return response.items
    }

    func getEvents(withId id: Int, atPage page: Int) async throws -> [EventResponse] {
        guard let url = URL.User.events(withId: id, atPage: page) else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }

        let response: EventsResponse = try await handleDataTask(securedSession(withToken: token), from: url)
        return response.items
    }

    func getTags(withId id: Int) async throws -> [UserTagResponse] {
        guard let url = URL.User.tags(withId: id) else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }

        let response: UserTagsResponse = try await handleDataTask(securedSession(withToken: token), from: url)
        return response.items
    }

    func getPrizes(withId id: Int) async throws -> [PrizeResponse] {
        guard let url = URL.User.prizes(withId: id) else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }

        let response: PrizesResponse = try await handleDataTask(securedSession(withToken: token), from: url)
        return response.items
    }

    // TODO: Check below is needed
    func getProfileDetails(withId id: Int) async throws -> UserResponse {
        guard let url = URL.User.get(withId: id) else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }

        let response: UserResponse = try await handleDataTask(securedSession(withToken: token), from: url)
        UserSettings.shared.save(response: response)
        return response
    }

    func getCreatedExhbts(withId id: Int, atPage page: Int) async throws -> [FeedResponse] {
        guard let url = URL.User.createdExhbts(withId: id, atPage: page) else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }
        let response: FeedsResponse = try await handleDataTask(securedSession(withToken: token), from: url)
        return response.items
    }

    func getParticipatedExhbts(withId id: Int, atPage page: Int) async throws -> [FeedResponse] {
        guard let url = URL.User.participatedExhbts(withId: id, atPage: page) else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }
        let response: FeedsResponse = try await handleDataTask(securedSession(withToken: token), from: url)
        return response.items
    }

    func followers(withId id: Int, page: Int) async throws -> [FollowerResponse] {
        guard let url = URL.User.followers(withId: id, page: page) else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }
        let response: FollowersResponse = try await handleDataTask(securedSession(withToken: token), from: url)
        debugLog(url, response)
        return response.items
    }

    func followings(withId id: Int, page: Int) async throws -> [FollowerResponse] {
        guard let url = URL.User.followings(withId: id, page: page) else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }
        let response: FollowersResponse = try await handleDataTask(securedSession(withToken: token), from: url)
        return response.items
    }

    func followersSearch(withId id: Int, keyword: String, page: Int) async throws -> [FollowerResponse] {
        guard let url = URL.User.followersSearch(withId: id, keyword: keyword, page: page) else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }
        let response: FollowersResponse = try await handleDataTask(securedSession(withToken: token), from: url)
        return response.items
    }

    func followingsSearch(withId id: Int, keyword: String, page: Int) async throws -> [FollowerResponse] {
        guard let url = URL.User.followingsSearch(withId: id, keyword: keyword, page: page) else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }
        let response: FollowersResponse = try await handleDataTask(securedSession(withToken: token), from: url)
        return response.items
    }
}
