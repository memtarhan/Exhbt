//
//  FollowingStatus.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 13/05/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import UIKit

enum FollowingStatus: String, CaseIterable {
    case following
    case unfollowing

    var buttonTitle: String {
        switch self {
        case .following:
            return "Unfollow"
        case .unfollowing:
            return "Follow"
        }
    }

    var buttonBackgroundColor: UIColor {
        switch self {
        case .following:
            return .systemGray2
        case .unfollowing:
            return .systemBlue
        }
    }

    var buttonBackgroundImage: UIImage? {
        switch self {
        case .following:
            return UIImage(named: "Button-Unfollow")
        case .unfollowing:
            return UIImage(named: "Button-Follow")
        }
    }

    init(fromStatus status: Bool) {
        switch status {
        case true:
            self = .following
        case false:
            self = .unfollowing
        }
    }

    mutating func toggle() {
        switch self {
        case .following:
            self = .unfollowing
        case .unfollowing:
            self = .following
        }
    }
}
