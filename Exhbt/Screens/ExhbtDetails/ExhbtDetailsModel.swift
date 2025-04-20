//
//  ExhbtDetailsModel.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 05/04/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Foundation

struct ExhbtDetailsModel {
    private let service: ExhbtServiceProtocol

    init(service: ExhbtServiceProtocol) {
        self.service = service
    }

    func getExhbt(withId id: Int) async throws -> ExhbtDetailsResponse {
        try await service.getDetails(withId: id)
    }

    func deleteExhbt(withId id: Int) async throws {
        try await service.delete(withId: id)
    }

    func flagExhbt(_ exhbtId: Int) async {
        _ = try? await service.flag(exhbtId: exhbtId)
    }
}

struct SingleExhbtStatusModel {
    let id: Int
    let status: ExhbtStatus
    let remainingDescription: String
    let timeLeft: String
    let canJoin: Bool
    let isOwn: Bool
}

struct SingleExhbtCompetitorItem {
    let id: Int?
    let photo: String?
    let imageName: String?
    let name: String?
    let isExhbtUser: Bool
}

struct SingleExhbtHorizontalCompetitorModel {
    let id: Int?
    let photo: String?
    let accepted: Bool
    let isExhbtUser: Bool
}

struct SingleExhbtVerticalCompetitorModel {
    let sectionTitle: String
    let items: [SingleExhbtCompetitorItem]
}

struct SingleExhbtCompetitorsModel {
    let title: String
    let countDescription: String
    let horizontalCompetitors: [SingleExhbtHorizontalCompetitorModel]
    let verticalCompetitors: [SingleExhbtVerticalCompetitorModel]
    let canJoin: Bool
    let isOwn: Bool
    let status: ExhbtStatus
}

struct SingleExhbtSubmissionsModel {
    let title: String
    let countDescription: String
    let isLocked: Bool
    let submissions: [SingleExhbtSubmissionModel]
}

struct SingleExhbtSubmissionModel {
    let photo: String
    let voteCount: Int
}

struct SingleExhbtSettingsModel {
    let isLocked: Bool
}
