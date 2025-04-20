//
//  UpdateProfileModel.swift
//  Exhbt
//
//  Created by Rakhmatov Bekzod on 23/04/23.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Foundation
import UIKit

struct UpdateProfileModel {
    private let service: MeServiceProtocol
    private let realtimeSyncService: MeRealtimeSyncService

    init(service: MeServiceProtocol, realtimeSyncService: MeRealtimeSyncService) {
        self.service = service
        self.realtimeSyncService = realtimeSyncService
    }

    func update(fullName: String?, biography: String?, voteStyle: VoteStyle?) async throws -> UserResponse {
        let response = try await service.updateDetails(fullName: fullName, biography: biography, voteStyle: voteStyle)
        realtimeSyncService.shouldReloadInfo()
        return response
    }

    func update(username: String) async throws -> UsernameUpdateResponse {
        let response = try await service.update(username: username)
        realtimeSyncService.shouldReloadInfo()
        return response
    }
}

enum UpdateProfileFieldType {
    case username
    case fullName
    case bio

    var title: String? {
        switch self {
        case .username:
            return "Username"
        case .fullName:
            return "Name"
        case .bio:
            return "About me"
        }
    }

    var placeholder: String? {
        switch self {
        case .username:
            return "Enter your username"
        case .fullName:
            return "Enter your name"
        case .bio:
            return "Enter your bio"
        }
    }

    var defaultValue: String? {
        switch self {
        case .username:
            return UserSettings.shared.username
        case .fullName:
            return UserSettings.shared.fullName
        case .bio:
            return UserSettings.shared.biography
        }
    }
}
