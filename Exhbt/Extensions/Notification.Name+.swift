//
//  Notification.Name+.swift
//  Exhbt
//
//  Created by Mehmet Tarhan Personal on 27/05/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let didUpdateCompetition = Notification.Name("didUpdateCompetition")
    static let didUpdateProfile = Notification.Name("didUpdateProfile")
    static let didReceiveInvitationToExhbt = Notification.Name("didReceiveInvitationToExhbt")

    static let shouldReloadExhbts = Notification.Name("shouldReloadExhbts")

    static let newExhbtAvailableNotification = Notification.Name("newExhbtAvailableNotification")
    static let exhbtUpdateAvailableNotification = Notification.Name("exhbtUpdateAvailableNotification")

    static let newEventAvailableNotification = Notification.Name("newEventAvailableNotification")
    static let eventUpdateAvailableNotification = Notification.Name("eventUpdateAvailableNotification")

    static let newPostLikeAvailableNotification = Notification.Name("newPostLikeAvailableNotification")
    static let newPostDislikeAvailableNotification = Notification.Name("newPostDislikeAvailableNotification")

    static let shouldReloadMeSubmissions = Notification.Name("shouldReloadProfileSubmissions")
    static let shouldReloadMeProfilePhoto = Notification.Name("shouldReloadMeProfilePhoto")
    static let shouldReloadMeCoinsCount = Notification.Name("shouldReloadMeCoinsCount")
    static let shouldReloadMePrizesCount = Notification.Name("shouldReloadMePrizesCount")
    static let shouldReloadMeFollowersCount = Notification.Name("shouldReloadMeFollowersCount")
    static let shouldReloadMeFollowingsCount = Notification.Name("shouldReloadMeFollowingsCount")
    static let shouldReloadMeInfo = Notification.Name("shouldReloadMeInfo")

}
