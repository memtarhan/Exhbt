//
//  NewCompetitionModel.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 03/08/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import Photos
import UIKit

struct NewCompetitionModel {
    private let competitionService: CompetitionServiceProtocol
    private let exhbtService: ExhbtServiceProtocol
    private let realtimeSync: ExhbtsRealtimeSyncService
    private let meRealtimeSync: MeRealtimeSyncService

    init(competitionService: CompetitionServiceProtocol,
         exhbtService: ExhbtServiceProtocol,
         realtimeSync: ExhbtsRealtimeSyncService,
         meRealtimeSync: MeRealtimeSyncService) {
        self.competitionService = competitionService
        self.exhbtService = exhbtService
        self.realtimeSync = realtimeSync
        self.meRealtimeSync = meRealtimeSync
    }

    func checkEligibility() async throws {
        try await exhbtService.checkEligibility()
    }

    func create(exhbtId: Int, asset: CCAsset?) async throws {
        try await competitionService.createCompetition(withAsset: asset, forExhbt: exhbtId)
    }

    func joinExhbt(exhbtId: Int, withInvitationId invitationId: Int, withAsset asset: CCAsset?) async throws {
        try await exhbtService.join(exhbtId: exhbtId, withInvitationId: invitationId, withAsset: asset)
        realtimeSync.notifyExhbtUpdateAvailable(exhbtId: exhbtId)
        meRealtimeSync.shouldReloadCoinsCount()
        meRealtimeSync.shouldReloadSubmissions()
    }

    func joinExhbt(exhbtId: Int, withAsset asset: CCAsset?) async throws {
        try await exhbtService.join(exhbtId: exhbtId, withInvitationId: nil, withAsset: asset)
        realtimeSync.notifyExhbtUpdateAvailable(exhbtId: exhbtId)
        meRealtimeSync.shouldReloadCoinsCount()
        meRealtimeSync.shouldReloadSubmissions()
    }

    struct RequestModel {
        let asset: PHAsset?
        let image: UIImage?
    }
}

enum NewCompetitionType {
    case new
    case join
    case joinWithInvitation

    var title: String {
        switch self {
        case .new:
            return "Add Competition"
        case .join, .joinWithInvitation:
            return "Join Competition"
        }
    }

    var buttonTitle: String {
        switch self {
        case .new:
            return "Create Exhbt"
        case .join, .joinWithInvitation:
            return "Join"
        }
    }
}
