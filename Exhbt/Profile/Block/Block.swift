//
//  Block.swift
//  Exhbt
//
//  Created by Shouvik Paul on 1/11/21.
//  Copyright © 2021 Exhbt LLC. All rights reserved.
//

import Foundation

enum BlockField: String {
    case userID
    case blockedID
    case createdAt
}

struct Block {
    var userID: String
    var blockedID: String
    var createdAt: String
    var createdDate: Date {
        return Utilities.dateFormatter.date(from: createdAt) ?? Date(timeIntervalSince1970: 0)
    }
    
    init?(from dict: [String: Any]) {
        guard let userID = dict[BlockField.userID.rawValue] as? String,
            let blockedID = dict[BlockField.blockedID.rawValue] as? String,
            let createdAt = dict[BlockField.createdAt.rawValue] as? String
        else { return nil }
        
        self.userID = userID
        self.blockedID = blockedID
        self.createdAt = createdAt
    }
    
    init(
        userID: String,
        blockedID: String
    ) {
        self.userID = userID
        self.blockedID = blockedID
        
        self.createdAt = Utilities.getCurrentDateString()
    }
    
    func toDict() -> [String: Any] {
        return [
            BlockField.userID.rawValue: userID,
            BlockField.blockedID.rawValue: blockedID,
            BlockField.createdAt.rawValue: createdAt
        ]
    }
}
