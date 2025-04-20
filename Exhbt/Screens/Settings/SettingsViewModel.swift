//
//  SettingsViewModel.swift
//  Exhbt
//
//  Created by Rakhmatov Bekzod on 10/04/23.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import UIKit

struct SettingsData {
    let section: String
    var items: [SettingsItem]
}

struct SettingsItem {
    let type: SettingsItemType
    var subtitle: String?
    var toggle: Bool?
    init(type: SettingsItemType, subtitle: String? = nil, toggle: Bool? = nil) {
        self.type = type
        self.subtitle = subtitle
        self.toggle = toggle
    }
}

enum SettingsItemType {
    case profileAccount
    case notifications
    case downloadData
    case logout
    case reportBug
    case suggestFeature
    case aboutExhbt
    case termsOfService
    case privacyPolicy
    
    func displayName() -> String {
        switch self {
        case .profileAccount:
            return "Profile & Account"
        case .notifications:
            return "Notifications"
        case .downloadData:
            return "Download Data"
        case .logout:
            return "Log out"
        case .reportBug:
            return "Report a Bug"
        case .suggestFeature:
            return "Suggest a Feature"
        case .aboutExhbt:
            return "About Exhbt"
        case .termsOfService:
            return "Terms of Service"
        case .privacyPolicy:
            return "Privacy Policy"
        }
    }
}


class SettingsViewModel {
    
    var settings = [
        SettingsData(
            section: "",
            items: [
                SettingsItem(type: .profileAccount),
                SettingsItem(type: .notifications)
            ]
        ),
        SettingsData(
            section: "PRIVACY & DATA",
            items: [
                SettingsItem(type: .downloadData)
            ]
        ),
        SettingsData(
            section: "",
            items: [
                SettingsItem(type: .logout)
            ]
        ),
        SettingsData(
            section: "Help",
            items: [
                SettingsItem(type: .reportBug),
                SettingsItem(type: .suggestFeature)
            ]
        ),
        SettingsData(
            section: "About",
            items: [
                SettingsItem(type: .aboutExhbt),
                SettingsItem(type: .termsOfService),
                SettingsItem(type: .privacyPolicy)
            ]
        )
    ]
}
