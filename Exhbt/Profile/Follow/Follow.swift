//
//  Follow.swift
//  Exhbt
//
//  Created by Shouvik Paul on 9/15/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import Foundation

enum FollowField: String {
    case userID
    case followedID
    case createdAt
}

struct Follow {
    var userID: String
    var followedID: String
    var createdAt: String
    var createdDate: Date {
        return Utilities.dateFormatter.date(from: createdAt) ?? Date(timeIntervalSince1970: 0)
    }
    
    init?(from dict: [String: Any]) {
        guard let userID = dict[FollowField.userID.rawValue] as? String,
            let followedID = dict[FollowField.followedID.rawValue] as? String,
            let createdAt = dict[FollowField.createdAt.rawValue] as? String
        else { return nil }
        
        self.userID = userID
        self.followedID = followedID
        self.createdAt = createdAt
    }
    
    init(
        userID: String,
        followedID: String
    ) {
        self.userID = userID
        self.followedID = followedID
        
        self.createdAt = Utilities.getCurrentDateString()
    }
    
    func toDict() -> [String: Any] {
        return [
            FollowField.userID.rawValue: userID,
            FollowField.followedID.rawValue: followedID,
            FollowField.createdAt.rawValue: createdAt
        ]
    }
}
