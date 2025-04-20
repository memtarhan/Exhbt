//
//  MeModel.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 12/05/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Foundation

struct MeModel {
    private let service: MeServiceProtocol

    init(service: MeServiceProtocol) {
        self.service = service
    }

    func getDetails() async throws -> UserResponse {
        try await service.getDetails()
    }

    func getTags() async throws -> [UserTagResponse] {
        try await service.getTags()
    }

    func getGallery(atPage page: Int) async throws -> [GalleryDisplayModel] {
        let response = try await service.getSubmissions(atPage: page)
        return response.map { GalleryDisplayModel.from(response: $0) }
    }

    func getPublicExhbts(atPage page: Int) async throws -> [ExhbtPreviewDisplayModel] {
        let response = try await service.getPublicExhbts(atPage: page)
        return response.map { ExhbtPreviewDisplayModel.from(response: $0) }
    }

    func getPrivateExhbts(atPage page: Int) async throws -> [ExhbtPreviewDisplayModel] {
        let response = try await service.getPrivateExhbts(atPage: page)
        return response.map { ExhbtPreviewDisplayModel.from(response: $0) }
    }

    func getEvents(atPage page: Int) async throws -> [EventDisplayModel] {
        let response = try await service.getEvents(atPage: page)
        return response.map { EventDisplayModel.from(response: $0) }
    }
}
