//
//  ContentType.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 01/12/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Foundation

enum ContentType: Int, CaseIterable {
    case photo = 1
    case video
}

// MARK: - init

extension ContentType {
    init(fromResponse response: MediaTypeResponse) {
        switch response {
        case .image: self = .photo
        case .video: self = .video
        }
    }
}
