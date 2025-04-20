//
//  ExhbtContentModel.swift
//  Exhbt
//
//  Created by Adem Tarhan on 19.09.2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Foundation

class ExhbtContentModel {
    private let exhbtService: ExhbtServiceProtocol

    init(exhbtService: ExhbtServiceProtocol) {
        self.exhbtService = exhbtService
    }

    func getExhbt(withId id: Int) async throws -> ExhbtResponse {
        try await exhbtService.get(withId: id)
    }
}
