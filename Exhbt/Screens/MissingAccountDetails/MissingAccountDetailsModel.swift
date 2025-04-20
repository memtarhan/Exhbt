//
//  MissingAccountDetailsModel.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 03/09/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import UIKit

struct MissingAccountDetailsModel {
    private let service: MeServiceProtocol
    private let realtimeSyncService: MeRealtimeSyncService

    init(service: MeServiceProtocol,
         realtimeSyncService: MeRealtimeSyncService) {
        self.service = service
        self.realtimeSyncService = realtimeSyncService
    }

    func save(username: String) async throws -> UsernameUpdateResponse {
        let response = try await service.update(username: username)
        realtimeSyncService.shouldReloadInfo()
        return response
    }

    func save(fullName: String?, biography: String?) async throws -> UserResponse {
        let response = try await service.updateDetails(fullName: fullName, biography: biography, voteStyle: nil)
        realtimeSyncService.shouldReloadInfo()
        return response
    }

    func saveProfilePhoto(asset: CCAsset) async throws -> UploadResponse {
        let response = try await service.updateProfilePhoto(asset: asset)
        realtimeSyncService.shouldReloadImage()
        return response
    }
}
