//
//  GalleryGridModel.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 03/05/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Foundation

struct GalleryGridModel {
    let service: ProfileServiceProtocol

    func get(atPage page: Int) async throws -> [UserSubmissionResponse] {
        try await service.getSubmissions(atPage: page)
    }
}
