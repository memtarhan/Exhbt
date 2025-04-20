//
//  EmptyStateType.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 15/09/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Foundation

enum EmptyStateType: String, CaseIterable {
    case feeds
    case exhbts
    case notifications
    case events
    case posts

    var title: String {
        switch self {
        case .feeds: return "No Feeds available"
        case .exhbts: return "No Exhbts available"
        case .notifications: return "No Notifications available"
        case .events: return "No Events available"
        case .posts: return "No Posts available"
        }
    }

    var subtitle: String? {
        switch self {
        case .feeds, .notifications: return "Please check back with us later"
        case .exhbts: return "You can create an Exhbt with Plus(+) button"
        case .events: return "You can create an Event with Plus(+) button"
        case .posts: return "You can create a Post with Plus(+) button"
        }
    }

    var imageName: String? {
        switch self {
        case .feeds: return "hand.thumbsup.fill"
        case .exhbts: return "magnifyingglass"
        case .notifications: return "bell.fill"
        case .events: return "calendar"
        case .posts: return "square.and.pencil"
        }
    }
}
