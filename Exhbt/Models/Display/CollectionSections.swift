//
//  Sections.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 12/05/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Foundation

// MARK: Please sort models by name

// MARK: CollectionSection - Root

protocol CollectionSection: CaseIterable {
    var id: Int { get }
    var title: String? { get }

    init?(fromId id: Int)
}

// MARK: - PrizeSection

enum PrizeSection: CollectionSection {
    case main

    var id: Int {
        return 0
    }

    var title: String? { nil }

    init?(fromId id: Int) {
        switch id {
        case 0:
            self = .main
        default:
            return nil
        }
    }
}

// MARK: - EventResultSection

enum EventsSection: CollectionSection {
    case preview

    var id: Int {
        return 0
    }

    var title: String? { nil }

    init?(fromId id: Int) {
        switch id {
        case 0:
            self = .preview
        default:
            return nil
        }
    }
}

// MARK: - NotificationSection

enum EventPostSection: CollectionSection {
    case main

    var id: Int { 0 }

    var title: String? { nil }

    init?(fromId id: Int) {
        self = .main
    }
}

// MARK: - ExhbtResultSection

enum ExhbtResultSection: CollectionSection {
    case preview
    case topRank
    case bottomRank

    var id: Int {
        switch self {
        case .preview:
            return 0
        case .topRank:
            return 1
        case .bottomRank:
            return 2
        }
    }

    var title: String? { nil }

    init?(fromId id: Int) {
        switch id {
        case 0:
            self = .preview
        case 1:
            self = .topRank
        case 2:
            self = .bottomRank
        default:
            return nil
        }
    }
}

// MARK: - ExploreSection

enum ExhbtsSection: CollectionSection {
    case tags, exhbts

    var id: Int {
        switch self {
        case .tags:
            return 0
        case .exhbts:
            return 1
        }
    }

    var title: String? { nil }

    init?(fromId id: Int) {
        switch id {
        case 0:
            self = .tags
        case 1:
            self = .exhbts
        default:
            return nil
        }
    }
}

// MARK: - Explore Search

enum ExploreSearchExhbtSection {
    case exhbts
}

// MARK: - Explore Search User

enum ExploreSearchUserSection {
    case users
}

// MARK: - FeedsSection

enum FeedsSection: CollectionSection {
    case main

    var id: Int {
        switch self {
        case .main:
            return 0
        }
    }

    var title: String? { nil }

    init?(fromId id: Int) {
        switch id {
        case 0:
            self = .main

        default:
            return nil
        }
    }
}

// MARK: - LeaderboardSection

enum FollowsSection: CollectionSection {
    case followers
    case followings

    var id: Int {
        switch self {
        case .followers:
            return 0
        case .followings:
            return 1
        }
    }

    var title: String? { nil }

    init?(fromId id: Int) {
        switch id {
        case 0:
            self = .followers
        case 1:
            self = .followings
        default:
            return nil
        }
    }
}

// MARK: - GalleryGridSection

enum GalleryGridSection: CollectionSection {
    case main

    var id: Int {
        switch self {
        case .main:
            return 0
        }
    }

    var title: String? { nil }

    init?(fromId id: Int) {
        switch id {
        case 0:
            self = .main

        default:
            return nil
        }
    }
}

// MARK: - LeaderboardSection

enum LeaderboardSection: CollectionSection {
    case categories
    case users

    var id: Int {
        switch self {
        case .categories:
            return 0
        case .users:
            return 1
        }
    }

    var title: String? { nil }

    init?(fromId id: Int) {
        switch id {
        case 0:
            self = .categories
        case 1:
            self = .users
        default:
            return nil
        }
    }
}

// MARK: - MeSection

enum MeSection: CollectionSection {
    case details
    case publicExhbts
    case gallery
    case events
    case privateExhbts

    var id: Int {
        switch self {
        case .details:
            return 0
        case .publicExhbts:
            return 1
        case .gallery:
            return 2
        case .events:
            return 3
        case .privateExhbts:
            return 4
        }
    }

    var title: String? { nil }

    init?(fromId id: Int) {
        switch id {
        case 0:
            self = .details
        case 1:
            self = .publicExhbts
        case 2:
            self = .gallery
        case 3:
            self = .events
        case 4:
            self = .privateExhbts
        default:
            return nil
        }
    }
}

// MARK: - NotificationSection

enum NotificationSection: CollectionSection {
    case main

    var id: Int { 0 }

    var title: String? { nil }

    init?(fromId id: Int) {
        self = .main
    }
}

// MARK: - UserSection

enum UserSection: CollectionSection {
    case details
    case publicExhbts
    case gallery
    case events

    var id: Int {
        switch self {
        case .details:
            return 0
        case .publicExhbts:
            return 1
        case .gallery:
            return 2
        case .events:
            return 3
        }
    }

    var title: String? { nil }

    init?(fromId id: Int) {
        switch id {
        case 0:
            self = .details
        case 1:
            self = .publicExhbts
        case 2:
            self = .gallery
        case 3:
            self = .events
        default:
            return nil
        }
    }
}

// MARK: - VotingSection

enum VotingSection: CollectionSection {
    case full
    case thumbnail

    var id: Int {
        switch self {
        case .full:
            return 0
        case .thumbnail:
            return 1
        }
    }

    var title: String? { nil }

    init?(fromId id: Int) {
        switch id {
        case 0:
            self = .full
        case 1:
            self = .thumbnail
        default:
            return nil
        }
    }
}

enum ExhbtContentSection: CollectionSection {
    case full
    case thumbnail

    var id: Int {
        switch self {
        case .full:
            return 0
        case .thumbnail:
            return 1
        }
    }

    var title: String? { nil }

    init?(fromId id: Int) {
        switch id {
        case 0:
            self = .full
        case 1:
            self = .thumbnail
        default:
            return nil
        }
    }
}
