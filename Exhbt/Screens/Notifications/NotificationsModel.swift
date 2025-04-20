//
//  NotificationsModel.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 17/09/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import SwiftUI
import UIKit

class NotificationsModel {
    private let service: MeServiceProtocol
    private let eventService: EventServiceProtocol

    init(service: MeServiceProtocol, eventService: EventServiceProtocol) {
        self.service = service
        self.eventService = eventService
    }

    func get(atPage page: Int) async throws -> [NotificationResponse] {
        try await service.getNotifications(atPage: page)
    }

    func read(withId id: Int) async throws {
        try await service.readNotification(withId: id)
    }
    
    func checkEligibility() async throws -> UserEligibilityResponse {
        try await service.getEligibility()
    }
    
    func join(eventId event: Int) async throws {
        try await eventService.join(eventId: event)
    }
}
