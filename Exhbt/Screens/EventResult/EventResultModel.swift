//
//  EventResultModel.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 17/12/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Foundation

class EventResultModel {
    private let service: EventServiceProtocol

    init(service: EventServiceProtocol) {
        self.service = service
    }

    func getResult(withId id: Int) async throws -> EventResultResponse {
        try await service.getResult(withId: id)
    }
}
