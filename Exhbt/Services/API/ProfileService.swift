//
//  ProfileService.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 27/07/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import Foundation
import Kingfisher
import Photos
import UIKit

// TODO: Move these to MeService
protocol ProfileServiceProtocol: APIService {
    func getProfile() async throws -> UserResponse
    func save(token: String)
    func save(id: Int)
    func update(username: String) async throws -> UsernameUpdateResponse
    func updateProfilePhoto(image: UIImage) async throws -> UploadResponse
    func createdExhbts(atPage page: Int) async throws -> [FeedResponse]
    func participatedExhbts(atPage page: Int) async throws -> [FeedResponse]
    func getFollowers(atPage: Int) async throws -> [FollowerResponse]
    func getFollowings(atPage: Int) async throws -> [FollowerResponse]
    func searchFollowers(withKeyword keyword: String, page: Int) async throws -> [FollowerResponse]
    func searchFollowings(withKeyword keyword: String, page: Int) async throws -> [FollowerResponse]
    func getSubmissions(atPage page: Int) async throws -> [UserSubmissionResponse]
}

class ProfileService: ProfileServiceProtocol {
    private var token: String? { UserSettings.shared.token }

    func getProfile() async throws -> UserResponse {
        guard let url = URL.Me.get() else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }
        let response: UserResponse = try await handleDataTask(securedSession(withToken: token), from: url)
        UserSettings.shared.save(response: response)
        return response
    }

    func save(token: String) {
        UserSettings.shared.token = token
    }

    func save(id: Int) {
        UserSettings.shared.id = id
    }

    func update(username: String) async throws -> UsernameUpdateResponse {
        guard let url = URL.Me.username() else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }
        let requestModel = UsernameUpdateRequest(username: username)
        let urlRequest = try requestModel.createURLRequest(withURL: url, encoder: encoder)
        let response: UsernameUpdateResponse = try await handleDataTask(securedSession(withToken: token), for: urlRequest)
        UserSettings.shared.username = username
        return response
    }

    func createdExhbts(atPage page: Int) async throws -> [FeedResponse] {
        guard let url = URL.Me.createdExhbts(atPage: page) else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }
        let response: FeedsResponse = try await handleDataTask(securedSession(withToken: token), from: url)
        return response.items
    }

    func participatedExhbts(atPage page: Int) async throws -> [FeedResponse] {
        guard let url = URL.Me.participatedExhbts(atPage: page) else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }
        let response: FeedsResponse = try await handleDataTask(securedSession(withToken: token), from: url)
        return response.items
    }

    func getFollowers(atPage: Int) async throws -> [FollowerResponse] {
        guard let url = URL.Me.followers(atPage: atPage) else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }
        let response: FollowersResponse = try await handleDataTask(securedSession(withToken: token), from: url)
        return response.items
    }

    func getFollowings(atPage: Int) async throws -> [FollowerResponse] {
        guard let url = URL.Me.followings(atPage: atPage) else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }
        let response: FollowersResponse = try await handleDataTask(securedSession(withToken: token), from: url)
        return response.items
    }

    func searchFollowers(withKeyword keyword: String, page: Int) async throws -> [FollowerResponse] {
        guard let url = URL.Me.followersSearch(withKeyword: keyword, page: page) else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }
        let response: FollowersResponse = try await handleDataTask(securedSession(withToken: token), from: url)
        return response.items
    }

    func searchFollowings(withKeyword keyword: String, page: Int) async throws -> [FollowerResponse] {
        guard let url = URL.Me.followingsSearch(withKeyword: keyword, page: page) else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }
        let response: FollowersResponse = try await handleDataTask(securedSession(withToken: token), from: url)
        return response.items
    }

    func getSubmissions(atPage page: Int) async throws -> [UserSubmissionResponse] {
        guard let url = URL.Me.submissions(atPage: page) else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }
        let response: UserSubmissionsResponse = try await handleDataTask(securedSession(withToken: token), from: url)
        return response.items
    }

    func updateProfilePhoto(image: UIImage) async throws -> UploadResponse {
        guard let url = URL.Me.profilePhoto() else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }

        let response = try await handleUploadTask(withImage: image, url: url, token: token)
        if let profilePhotoFull = UserSettings.shared.profilePhotoFull {
            KingfisherManager.shared.cache.removeImage(forKey: profilePhotoFull)
        }
        if let profilePhotoThumbnail = UserSettings.shared.profilePhotoThumbnail {
            KingfisherManager.shared.cache.removeImage(forKey: profilePhotoThumbnail)
        }
//        UserSettings.shared.profilePhotoThumbnail = response.url
//        UserSettings.shared.profilePhotoFull = response.url
        return response
    }
}
