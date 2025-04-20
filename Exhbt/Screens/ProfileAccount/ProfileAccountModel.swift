//
//  ProfileAccountModel.swift
//  Exhbt
//
//  Created by Rakhmatov Bekzod on 08/04/23.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Foundation
import UIKit

class ProfileAccountModel {
    private let service: MeServiceProtocol
    private let realtimeSyncService: MeRealtimeSyncService

    init(service: MeServiceProtocol,
         realtimeSyncService: MeRealtimeSyncService) {
        self.service = service
        self.realtimeSyncService = realtimeSyncService
    }

    func delete() async throws {
        try await service.delete()
    }

    func updateProfilePhoto(asset: CCAsset) async throws -> UploadResponse {
        let response = try await service.updateProfilePhoto(asset: asset)
        realtimeSyncService.shouldReloadImage()
        return response
    }
}
