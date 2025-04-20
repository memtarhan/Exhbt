//
//  NewExhbtModel.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 21/07/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import Photos
import UIKit

struct NewExhbtModel {
    let exhbtService: ExhbtServiceProtocol
    let competitionService: CompetitionServiceProtocol
    let realtimeSync: ExhbtsRealtimeSyncService
    let meRealtimeSync: MeRealtimeSyncService

    init(exhbtService: ExhbtServiceProtocol,
         competitionService: CompetitionServiceProtocol,
         realtimeSync: ExhbtsRealtimeSyncService,
         meRealtimeSync: MeRealtimeSyncService) {
        self.exhbtService = exhbtService
        self.competitionService = competitionService
        self.realtimeSync = realtimeSync
        self.meRealtimeSync = meRealtimeSync
    }

    func checkEligibility() async throws {
        try await exhbtService.checkEligibility()
    }

    func create(withAsset asset: CCAsset, tags: [String], description: String, exhbtType: ExhbtType) async throws -> ExhbtResponse {
        debugLog(self, "willCreateExhbt")
        let exhbt = try await exhbtService.create(tags: tags, description: description, exhbtType: exhbtType)
        debugLog(self, "didCreateExhbt exhbt \(exhbt)")

        Task(priority: .background) {
            try? await self.createCompetition(withAsset: asset, image: nil, forExhbt: exhbt.id, joining: false)
            meRealtimeSync.shouldReloadCoinsCount()
            meRealtimeSync.shouldReloadSubmissions()
            realtimeSync.notifyNewExhbtAvailable(exhbtId: exhbt.id)
        }

        return exhbt
    }

    private func createCompetition(withAsset asset: CCAsset?, image: UIImage?, forExhbt exhbt: Int, joining: Bool) async throws {
        if joining {
            if let invitationId = AppState.shared.exhbtInvitationId {
                try await exhbtService.join(exhbtId: exhbt, withInvitationId: invitationId, withAsset: asset)
            }

        } else {
            try await competitionService.createCompetition(withAsset: asset, forExhbt: exhbt)
        }
    }

    struct CategoryModel {
        let id: Int
        let image: String
        let title: String
        let category: Category
    }

    // TODO: Move this to Requests
    struct RequestModel {
        let tags: [String]
        let asset: PHAsset?
        let exhbtType: ExhbtStatusTypeResponse
    }
}

extension NewExhbtModel.CategoryModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: NewExhbtModel.CategoryModel, rhs: NewExhbtModel.CategoryModel) -> Bool {
        return lhs.id == rhs.id
    }
}
