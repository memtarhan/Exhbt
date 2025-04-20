//
//  MeService.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 12/05/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Kingfisher
import UIKit

protocol MeServiceProtocol: APIService {
    func getDetails() async throws -> UserResponse
    func delete() async throws
    func updateDetails(fullName: String?, biography: String?, voteStyle: VoteStyle?) async throws -> UserResponse
    func update(username: String) async throws -> UsernameUpdateResponse
    func updateProfilePhoto(asset: CCAsset) async throws -> UploadResponse
    func getEligibility() async throws -> UserEligibilityResponse
    func getSubmissions(atPage page: Int) async throws -> [UserSubmissionResponse]
    func getPublicExhbts(atPage page: Int) async throws -> [ExhbtPreviewResponse]
    func getPrivateExhbts(atPage page: Int) async throws -> [ExhbtPreviewResponse]
    func getVotedExhbts() async throws -> [FeedPreviewResponse]
    func getNotifications(atPage page: Int) async throws -> [NotificationResponse]
    func readNotification(withId id: Int) async throws
    func getNotificationsBadgeCount() async throws -> NotificationsBadgeCountResponse
    func saveNotificationsDeviceToken(_ deviceToken: String) async throws -> NotificationsDeviceTokenResponse
    func follow(withId id: Int) async throws
    func unfollow(withId id: Int) async throws
    func getFollowers(atPage: Int) async throws -> FollowersResponse
    func getFollowings(atPage: Int) async throws -> FollowersResponse
    func searchFollowers(withKeyword keyword: String, page: Int) async throws -> [FollowerResponse]
    func searchFollowings(withKeyword keyword: String, page: Int) async throws -> [FollowerResponse]
    func getEvents(atPage page: Int) async throws -> [EventResponse]
    func getTags() async throws -> [UserTagResponse]
    func getPrizes() async throws -> [PrizeResponse]
}

class MeService: MeServiceProtocol {
    private var token: String? { UserSettings.shared.token }

    func getDetails() async throws -> UserResponse {
        guard let url = URL.Me.get() else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }

        let response: UserResponse = try await handleDataTask(securedSession(withToken: token), from: url)
        UserSettings.shared.save(response: response)
        return response
    }

    func delete() async throws {
        guard let url = URL.Me.delete() else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }

        let requestModel = DeleteAccountRequest()
        let urlRequest = try requestModel.createURLRequest(withURL: url, encoder: encoder, httpMethod: "DELETE")

        let (_, response) = try await securedSession(withToken: token).data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw HTTPError.failed
        }
        if httpResponse.statusCode != 204 { throw HTTPError.failed }
        debugLog(self, "didDeleteAccount statusCode: \(httpResponse.statusCode)")
    }

    func updateDetails(fullName: String?, biography: String?, voteStyle: VoteStyle?) async throws -> UserResponse {
        guard let url = URL.Me.update() else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }
        let requestModel = ProfileUpdateRequest(fullName: fullName, biography: biography, voteStyleId: voteStyle?.id)
        let urlRequest = try requestModel.createURLRequest(withURL: url, encoder: encoder)

        let response: UserResponse = try await handleDataTask(securedSession(withToken: token), for: urlRequest)
        UserSettings.shared.save(response: response)
        return response
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

    func updateProfilePhoto(asset: CCAsset) async throws -> UploadResponse {
        guard let url = URL.Me.profilePhoto() else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }
        guard let image = asset.image else { throw UserError.wrongInput }

        let response = try await handleUploadTask(withImage: image, url: url, token: token)
        if let profilePhotoFull = UserSettings.shared.profilePhotoFull {
            KingfisherManager.shared.cache.removeImage(forKey: profilePhotoFull)
        }
        if let profilePhotoThumbnail = UserSettings.shared.profilePhotoThumbnail {
            KingfisherManager.shared.cache.removeImage(forKey: profilePhotoThumbnail)
        }
        UserSettings.shared.profilePhotoThumbnail = response.url
        UserSettings.shared.profilePhotoFull = response.url
        return response
    }

    func getEligibility() async throws -> UserEligibilityResponse {
        guard let url = URL.Me.elibility() else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }

        let response: UserEligibilityResponse = try await handleDataTask(securedSession(withToken: token), from: url)
        UserSettings.shared.coinsCount = response.coinsCount
        UserSettings.shared.save(eligibility: response)
        UserSettings.shared.save(durations: response)
        return response
    }

    func getSubmissions(atPage page: Int) async throws -> [UserSubmissionResponse] {
        guard let url = URL.Me.submissions(atPage: page) else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }

        let response: UserSubmissionsResponse = try await handleDataTask(securedSession(withToken: token), from: url)
        return response.items
    }

    func getPublicExhbts(atPage page: Int) async throws -> [ExhbtPreviewResponse] {
        guard let url = URL.Me.publicExhbts(atPage: page) else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }

        let response: ExhbtsPreviewResponse = try await handleDataTask(securedSession(withToken: token), from: url)
        return response.items
    }

    func getPrivateExhbts(atPage page: Int) async throws -> [ExhbtPreviewResponse] {
        guard let url = URL.Me.privateExhbts(atPage: page) else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }

        let response: ExhbtsPreviewResponse = try await handleDataTask(securedSession(withToken: token), from: url)
        return response.items
    }

    func getVotedExhbts() async throws -> [FeedPreviewResponse] {
        guard let url = URL.Me.votedExhbts() else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }

        let response: FeedsPreviewResponse = try await handleDataTask(securedSession(withToken: token), from: url)
        return response.items
    }

    func getNotifications(atPage page: Int) async throws -> [NotificationResponse] {
        guard let url = URL.Me.notifications(atPage: page) else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }
        let response: NotificationsResponse = try await handleDataTask(securedSession(withToken: token), from: url)
        return response.items
    }

    func readNotification(withId id: Int) async throws {
        guard let url = URL.Me.readNotification(withId: id) else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }
        let requestModel = NotificationsReadRequest()
        let urlRequest = try requestModel.createURLRequest(withURL: url, encoder: encoder)
        let (_, response) = try await securedSession(withToken: token).data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw HTTPError.failed
        }
        if httpResponse.statusCode != 201 { throw HTTPError.failed }
        debugLog(self, "didRead id: \(id) statusCode: \(httpResponse.statusCode)")
    }

    func getNotificationsBadgeCount() async throws -> NotificationsBadgeCountResponse {
        guard let url = URL.Me.notificationsBadgeCount() else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }

        let response: NotificationsBadgeCountResponse = try await handleDataTask(securedSession(withToken: token), from: url)
        return response
    }

    func saveNotificationsDeviceToken(_ deviceToken: String) async throws -> NotificationsDeviceTokenResponse {
        guard let url = URL.Me.notificationsDeviceToken() else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }

        let requestModel = NotificationsDeviceTokenRequest(token: deviceToken)
        let urlRequest = try requestModel.createURLRequest(withURL: url, encoder: encoder)

        let response: NotificationsDeviceTokenResponse = try await handleDataTask(securedSession(withToken: token), for: urlRequest)
        return response
    }

    func follow(withId id: Int) async throws {
        guard let url = URL.Me.follow(withId: id) else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }
        let requestModel = FollowRequest()
        let urlRequest = try requestModel.createURLRequest(withURL: url, encoder: encoder)
        let (_, response) = try await securedSession(withToken: token).data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw HTTPError.failed
        }
        if httpResponse.statusCode != 201 { throw HTTPError.failed }
        _ = try await getDetails()
        debugLog(self, "didFollow id: \(id) statusCode: \(httpResponse.statusCode)")
    }

    func unfollow(withId id: Int) async throws {
        guard let url = URL.Me.unfollow(withId: id) else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }
        let requestModel = UnfollowRequest()
        let urlRequest = try requestModel.createURLRequest(withURL: url, encoder: encoder, httpMethod: "DELETE")
        let (_, response) = try await securedSession(withToken: token).data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw HTTPError.failed
        }
        if httpResponse.statusCode != 204 { throw HTTPError.failed }
        _ = try await getDetails()
        debugLog(self, "didUnfollow id: \(id) statusCode: \(httpResponse.statusCode)")
    }

    func getFollowers(atPage: Int) async throws -> FollowersResponse {
        guard let url = URL.Me.followers(atPage: atPage) else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }
        let response: FollowersResponse = try await handleDataTask(securedSession(withToken: token), from: url)
        return response
    }

    func getFollowings(atPage: Int) async throws -> FollowersResponse {
        guard let url = URL.Me.followings(atPage: atPage) else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }
        let response: FollowersResponse = try await handleDataTask(securedSession(withToken: token), from: url)
        return response
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

    func getEvents(atPage page: Int) async throws -> [EventResponse] {
        guard let url = URL.Me.events(atPage: page) else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }

        let response: EventsResponse = try await handleDataTask(securedSession(withToken: token), from: url)
        return response.items
    }

    func getTags() async throws -> [UserTagResponse] {
        guard let url = URL.Me.tags() else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }

        let response: UserTagsResponse = try await handleDataTask(securedSession(withToken: token), from: url)
        return response.items
    }

    func getPrizes() async throws -> [PrizeResponse] {
        guard let url = URL.Me.prizes() else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }

        let response: PrizesResponse = try await handleDataTask(securedSession(withToken: token), from: url)
        return response.items
    }
}
