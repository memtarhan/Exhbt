//
//  EventModel.swift
//  Exhbt
//
//  Created by Adem Tarhan on 1.10.2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Foundation

class EventsModel {
    private let service: EventServiceProtocol
    private let meService: MeServiceProtocol

    init(service: EventServiceProtocol, meService: MeServiceProtocol) {
        self.service = service
        self.meService = meService
    }

    func checkEligibility() async throws -> UserEligibilityResponse {
        try await meService.getEligibility()
    }

    func join(eventId event: Int) async throws {
        try await service.join(eventId: event)
    }
    
    func getSingle(withId id: Int) async throws -> EventResponse {
        try await service.getSingle(withId: id)
    }

    func get(keyword: String?, 
             showNSFWContent: Bool,
             showAllEvents: Bool,
             sortByLocation: Bool,
             page: Int) async throws -> [EventResponse] {
        try await service.get(keyword: keyword, 
                              showNSFWContent: showNSFWContent,
                              showAllEvents: showAllEvents,
                              sortByLocation: sortByLocation,
                              page: page)
    }
}
