//
//  EventStatus.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 19/11/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import UIKit

enum EventStatus: Int, CaseIterable {
    case live = 1
    case finished
}

// MARK: - init

extension EventStatus {
    init(fromType type: EventStatusType) {
        switch type {
        case .live: self = .live
        case .finished: self = .finished
        }
    }

    init?(fromString string: String) {
        switch string {
        case "live": self = .live
        case "finished": self = .finished
        default: return nil
        }
    }
}

// MARK: - Attributes

extension EventStatus {
    var title: String {
        switch self {
        case .live: return "Live"
        case .finished: return "Finished"
        }
    }

    var color: UIColor {
        switch self {
        case .live: return .red
        case .finished: return .black
        }
    }
}
