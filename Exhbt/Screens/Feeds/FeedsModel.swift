//
//  FeedsModel.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 12/06/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import Foundation

struct FeedsModel {
    private let service: FeedsServiceProtocol

    init(service: FeedsServiceProtocol) {
        self.service = service
    }

    func get(atPage page: Int) async throws -> [FeedPreviewResponse] {
        try await service.get(atPage: page)
    }
}
