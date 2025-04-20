//
//  HomeModel.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 02/09/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Foundation

struct HomeModel {
    private let meService: MeServiceProtocol

    init(meService: MeServiceProtocol) {
        self.meService = meService
    }

    func getNotificationsBadgeCount() async throws -> NotificationsBadgeCountResponse {
        try await meService.getNotificationsBadgeCount()
    }
}
