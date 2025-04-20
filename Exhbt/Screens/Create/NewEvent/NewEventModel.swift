//
//  NewEventModel.swift
//  Exhbt
//
//  Created by Adem Tarhan on 29.09.2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Photos
import UIKit

struct NewEventRequestModel {
    let title: String
    let description: String
    let coverAsset: CCAsset
    let durationInDays: Int
    let type: EventType
    let isNSFW: Bool
    let address: AddressModel
}

class NewEventModel {
    private let service: EventServiceProtocol
    private let meService: MeServiceProtocol
    private let realtimeSync: EventsRealtimeSyncService
    private let meRealtimeSync: MeRealtimeSyncService

    init(service: EventServiceProtocol,
         meService: MeServiceProtocol,
         realtimeSync: EventsRealtimeSyncService,
         meRealtimeSync: MeRealtimeSyncService) {
        self.service = service
        self.meService = meService
        self.realtimeSync = realtimeSync
        self.meRealtimeSync = meRealtimeSync
    }

    func checkEligibility() async throws -> UserEligibilityResponse {
        try await meService.getEligibility()
    }

    func create(withRequest request: NewEventRequestModel) async throws {
        do {
            let response = try await service.create(withRequest: request)
            if let coverPhoto = request.coverAsset.image {
                Task(priority: .background, operation: {
                    _ = try? await self.service.uploadCoverPhoto(asset: coverPhoto, eventId: response.id)
                    realtimeSync.notifyNewEventAvailable(eventId: response.id)
                    meRealtimeSync.shouldReloadCoinsCount()
                    meRealtimeSync.shouldReloadSubmissions()
                })
            }

        } catch {
            throw error
        }
    }
}
