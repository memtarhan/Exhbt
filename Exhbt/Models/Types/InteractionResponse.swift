//
//  Interaction.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 25/06/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Foundation

enum InteractionResponse: String, APIResponse {
    case like
    case dislike
}

enum PostInteractionType: String {
    case like
    case dislike
}

extension PostInteractionType {
    init(withResponse type: InteractionResponse) {
        switch type {
        case .like: self = .like
        case .dislike: self = .dislike
        }
    }

    init?(fromString string: String) {
        switch string {
        case "like": self = .like
        case "dislike": self = .dislike
        default: return nil
        }
    }
}
