//
//  Notification.swift
//  Exhbt
//
//  Created by Shouvik Paul on 6/24/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import Foundation

enum NotificationField: String {
    case userID
    case creatorID 
    case type
    case seen
    case competitionID
    case coins
    case createdAt
}

enum NotificationType: String {
    case invite
    case competitionExpiration
    case follow
    case followRequest
}

struct Notification {
    var userID: String
    var creatorID: String?
    var type: NotificationType
    var seen: Bool
    var competitionID: String?
    var coins: Int?
    var creator: User?
    var createdAt: String
    var createdDate: Date {
        return Utilities.dateFormatter.date(from: createdAt) ?? Date(timeIntervalSince1970: 0)
    }
    
    init?(from dict: [String: Any]) {
        guard let userID = dict[NotificationField.userID.rawValue] as? String,
            let typeStr = dict[NotificationField.type.rawValue] as? String,
            let type = NotificationType.init(rawValue: typeStr),
            let createdAt = dict[NotificationField.createdAt.rawValue] as? String
        else { return nil }
        self.userID = userID
        self.type = type
        self.creatorID = dict[NotificationField.creatorID.rawValue] as? String
        self.seen = dict[NotificationField.seen.rawValue] as? Bool ?? false
        self.competitionID = dict[NotificationField.competitionID.rawValue] as? String
        self.coins = dict[NotificationField.coins.rawValue] as? Int
        self.createdAt = createdAt
    }
    
    init(
        userID: String,
        type: NotificationType,
        competitionID: String? = nil,
        coins: Int? = nil,
        creatorID: String? = nil
    ) {
        self.userID = userID
        self.type = type
        self.competitionID = competitionID
        self.coins = coins
        self.creatorID = creatorID
        
        self.createdAt = Utilities.getCurrentDateString()
        
        seen = false
    }
    
    func toDict() -> [String: Any] {
        var dict: [String: Any] = [
            NotificationField.userID.rawValue: userID,
            NotificationField.type.rawValue: type.rawValue,
            NotificationField.createdAt.rawValue: createdAt
        ]
        if let competitionID = competitionID {
            dict[NotificationField.competitionID.rawValue] = competitionID
        }
        if let coins = coins {
            dict[NotificationField.coins.rawValue] = coins
        }
        if let creatorID = creatorID {
            dict[NotificationField.creatorID.rawValue] = creatorID
        }
        return dict
    }
}
