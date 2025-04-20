//
//  EventService.swift
//  Exhbt
//
//  Created by Adem Tarhan on 29.09.2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import MapKit
import Photos
import UIKit

protocol EventServiceProtocol: APIService {
    func getResult(withId id: Int) async throws -> EventResultResponse
    func getSingle(withId id: Int) async throws -> EventResponse
    func get(keyword: String?,
             showNSFWContent: Bool,
             showAllEvents: Bool,
             sortByLocation: Bool,
             page: Int) async throws -> [EventResponse]
    func create(withRequest request: NewEventRequestModel) async throws -> EventResponse
    func uploadCoverPhoto(asset: UIImage, eventId: Int) async throws -> UploadResponse
    func getEvent(withId id: Int) async throws -> EventResponse
    func join(eventId: Int) async throws -> EventResponse
    func post(eventId: Int, asset: CCAsset, task: URLSessionTaskDelegate?) async throws -> PostResponse
    func getPosts(forEvent eventId: Int, page: Int) async throws -> [PostResponse]
    func getShareInvitation(forEvent eventId: Int) async throws -> EventInvitationResponse
    func invite(invitees: [ContactDisplayModel], eventId: Int) async throws -> EventInvitationsResponse
    func invite(invitees: [FollowingContactDisplayModel], eventId: Int) async throws -> EventInvitationsResponse
}

class EventService: EventServiceProtocol {
    private let uploadService: UploadServiceProtocol
    private let meService: MeServiceProtocol
    private let realtimeSync: EventsRealtimeSyncService

    init(uploadService: UploadServiceProtocol,
         meService: MeServiceProtocol,
         realtimeSync: EventsRealtimeSyncService) {
        self.uploadService = uploadService
        self.meService = meService
        self.realtimeSync = realtimeSync
    }

    private var token: String? { UserSettings.shared.token }

    func getResult(withId id: Int) async throws -> EventResultResponse {
        guard let url = URL.Event.getResult(withId: id) else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }

        let response: EventResultResponse = try await handleDataTask(securedSession(withToken: token), from: url)
        return response
    }

    func getSingle(withId id: Int) async throws -> EventResponse {
        guard let url = URL.Event.getSingle(withId: id) else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }

        let response: EventResponse = try await handleDataTask(securedSession(withToken: token), from: url)
        return response
    }

    func get(keyword: String?,
             showNSFWContent: Bool,
             showAllEvents: Bool,
             sortByLocation: Bool,
             page: Int) async throws -> [EventResponse] {
        let location = UserSettings.shared.currentLocation

        guard let url = URL.Event.get(keyword: keyword,
                                      showNSFWContent: showNSFWContent,
                                      showAllEvents: showAllEvents,
                                      sortByLocation: sortByLocation,
                                      longitude: location?.longitude,
                                      latitude: location?.latitude,
                                      page: page) else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }

        let response: EventsResponse = try await handleDataTask(securedSession(withToken: token), from: url)
        return response.items
    }

    func create(withRequest request: NewEventRequestModel) async throws -> EventResponse {
        guard let url = URL.Event.create() else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }

        let typeRequest = EventTypeRequest(rawValue: request.type.rawValue)!
        let requestModel = NewEventRequest(title: request.title,
                                           description: request.description,
                                           durationInDays: request.durationInDays,
                                           nsfw: request.isNSFW,
                                           eventType: typeRequest,
                                           fullAddress: request.address.fullAddress,
                                           longitude: request.address.longitude,
                                           latitude: request.address.latitude)

        let urlRequest = try requestModel.createURLRequest(withURL: url, encoder: encoder)

        let response: NewEventResponse = try await handleDataTask(securedSession(withToken: token), for: urlRequest)
        UserSettings.shared.coinsCount = response.coinsCount
        return response.event
    }

    func uploadCoverPhoto(asset: UIImage, eventId: Int) async throws -> UploadResponse {
        try await uploadService.uploadEventCover(image: asset, eventId: eventId)
    }

    func getEvent(withId id: Int) async throws -> EventResponse {
        guard let url = URL.Event.get(exhbtId: id) else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }

        let response: EventResponse = try await handleDataTask(securedSession(withToken: token), from: url)
        return response
    }

    func join(eventId: Int) async throws -> EventResponse {
        guard let url = URL.Event.join(eventId: eventId) else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }

        let requestModel = EventJoinerRequest()
        let urlRequest = try requestModel.createURLRequest(withURL: url, encoder: encoder)

        let response: NewEventResponse = try await handleDataTask(securedSession(withToken: token), for: urlRequest)
        UserSettings.shared.coinsCount = response.coinsCount
        return response.event
    }

    func post(eventId: Int, asset: CCAsset, task: URLSessionTaskDelegate? = nil) async throws -> PostResponse {
        guard let url = URL.Event.post(eventId: eventId) else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }

        let requestModel = EventPostRequest()
        let urlRequest = try requestModel.createURLRequest(withURL: url, encoder: encoder)

        let response: PostResponse = try await handleDataTask(securedSession(withToken: token), for: urlRequest)

        Task(priority: .background) {
            _ = try await uploadService.upload(asset: asset, forPost: response.id, task: task)
            realtimeSync.notifyEventUpdateAvailable(eventId: eventId)
        }

        return response
    }

    func getPosts(forEvent eventId: Int, page: Int) async throws -> [PostResponse] {
        guard let url = URL.Event.posts(eventId: eventId, page: page) else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }

        let response: PostsResponse = try await handleDataTask(securedSession(withToken: token), from: url)
        return response.items
    }

    func getShareInvitation(forEvent eventId: Int) async throws -> EventInvitationResponse {
        guard let url = URL.Event.shareInvitation(eventId: eventId) else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }

        let response: EventInvitationResponse = try await handleDataTask(securedSession(withToken: token), from: url)
        return response
    }

    func invite(invitees: [ContactDisplayModel], eventId: Int) async throws -> EventInvitationsResponse {
        guard let url = URL.Event.invite(eventId: eventId) else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }

        let newJoinerRequests = invitees
            .map { NewEventJoinerRequest(eventUserId: nil, phoneNumber: $0.phoneNumber) }

        let requestModel = EventJoinersAddRequest(invitees: newJoinerRequests)
        let urlRequest = try requestModel.createURLRequest(withURL: url, encoder: encoder)

        let response: EventInvitationsResponse = try await handleDataTask(securedSession(withToken: token), for: urlRequest)
        return response
    }

    func invite(invitees: [FollowingContactDisplayModel], eventId: Int) async throws -> EventInvitationsResponse {
        guard let url = URL.Event.invite(eventId: eventId) else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }

        let newJoinerRequests = invitees
            .map { NewEventJoinerRequest(eventUserId: $0.userId, phoneNumber: nil) }

        let requestModel = EventJoinersAddRequest(invitees: newJoinerRequests)
        let urlRequest = try requestModel.createURLRequest(withURL: url, encoder: encoder)

        let response: EventInvitationsResponse = try await handleDataTask(securedSession(withToken: token), for: urlRequest)
        return response
    }
}
