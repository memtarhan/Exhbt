//
//  ExhbtResultModel.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 30/05/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Foundation

struct ExhbtResultModel {
    private let service: ExhbtServiceProtocol

    init(service: ExhbtServiceProtocol) {
        self.service = service
    }

    func get(withId id: Int) async throws -> ExhbtResultWholeResponse {
        try await service.getResult(withId: id)
    }
}
