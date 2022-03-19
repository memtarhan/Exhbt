//
//  FeedEntity.swift
//  Exhbt
//
//  Created Mehmet Tarhan on 03/03/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import UIKit

struct FeedEntity {
    struct Feed {
        struct ViewModel {
            let id: String
        }
    }
}

/// - to confirm UITableViewDiffableDataSource
extension FeedEntity.Feed.ViewModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: FeedEntity.Feed.ViewModel, rhs: FeedEntity.Feed.ViewModel) -> Bool {
        return lhs.id == rhs.id
    }
}
