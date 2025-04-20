//
//  NotificationSettingsViewModel.swift
//  Exhbt
//
//  Created by Rakhmatov Bekzod on 10/04/23.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import UIKit

struct NotificationSettingData {
    let section: String
    var items: [NotificationSettingItem]
}

struct NotificationSettingItem {
    let type: NotificationSetttingItemType
    var subtitle: String?
    var toggle: Bool?
    init(type: NotificationSetttingItemType, subtitle: String? = nil, toggle: Bool? = nil) {
        self.type = type
        self.subtitle = subtitle
        self.toggle = toggle
    }
}

enum NotificationSetttingItemType {
    case pauseAll
    case contestUpdateAndResults
    case updatesFromUsersYouFollow
    case newFollowers
    case friendInvitationsResults
    
    func displayName() -> String {
        switch self {
        case .pauseAll:
            return "Pause All"
        case .contestUpdateAndResults:
            return "Contest Updates and Results"
        case .updatesFromUsersYouFollow:
            return "Updates from Users You Follow"
        case .newFollowers:
            return "New Followers"
        case .friendInvitationsResults:
            return "Friend Invitations Results"
        }
    }
}

class NotificationSettingsViewModel {
    
    var notificationSettings = [
        NotificationSettingData(
            section: "",
            items: [
                NotificationSettingItem(type: .pauseAll)
            ]
        ),
        NotificationSettingData(
            section: "PUSH NOTIFICATIONS",
            items: [
                NotificationSettingItem(type: .contestUpdateAndResults),
                NotificationSettingItem(type: .updatesFromUsersYouFollow),
                NotificationSettingItem(type: .newFollowers),
                NotificationSettingItem(type: .friendInvitationsResults)
            ]
        )
    ]
}
