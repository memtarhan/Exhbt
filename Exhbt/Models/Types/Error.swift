//
//  Error.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 24/07/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import Foundation

protocol ExError: Error, CustomStringConvertible {}

enum HTTPError: ExError {
    case failed
    case invalidEndpoint
    case invalidData
}

extension HTTPError {
    var description: String {
        switch self {
        case .failed:
            return "Failed to connect"
        case .invalidEndpoint:
            return "Invalid endpoint"
        case .invalidData:
            return "Invalid data"
        }
    }
}

enum UserError: ExError {
    case invalidToken
    case noVoteStyle
    case inEligible
    case wrongInput
}

extension UserError {
    var description: String {
        switch self {
        case .invalidToken:
            return "Invalid token"
        case .noVoteStyle:
            return "Vote style not found"
        case .inEligible:
            return "Not enough coin to create or participate."
        case .wrongInput:
            return "Incorrect data type"
        }
    }
}
