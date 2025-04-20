//
//  EventModel.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 02/01/2024.
//  Copyright © 2024 Exhbt LLC. All rights reserved.
//

import Foundation

class EventModel {
    private let service: EventServiceProtocol
    private let meService: MeServiceProtocol

    init(service: EventServiceProtocol, meService: MeServiceProtocol) {
        self.service = service
        self.meService = meService
    }

    func checkEligibility() async throws -> UserEligibilityResponse {
        try await meService.getEligibility()
    }

    func join(eventId event: Int) async throws -> EventResponse {
        try await service.join(eventId: event)
    }
    
    func getSingle(withId id: Int) async throws -> EventResponse {
        try await service.getSingle(withId: id)
    }

    
}
