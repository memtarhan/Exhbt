//
//  NewPostModel.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 16/10/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Photos
import UIKit

struct NewPostModel {
    private let service: EventServiceProtocol
    private let meService: MeServiceProtocol

    init(service: EventServiceProtocol,
         meService: MeServiceProtocol) {
        self.service = service
        self.meService = meService
    }

    func checkEligibility() async throws -> UserEligibilityResponse {
        try await meService.getEligibility()
    }
    
    func post(withAsset asset: CCAsset, eventId: Int, task: URLSessionTaskDelegate? = nil) async throws {
        _ = try await service.post(eventId: eventId, asset: asset, task: task)
    }
}
