//
//  LocalStorage.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 08/09/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import Foundation

struct LocalStorage {
    static var shared = LocalStorage()

    // MARK: - Current User (Me)

    @Storage(key: "currentUser_id", defaultValue: nil)
    var currentUserId: Int?

    @Storage(key: "currentUser_token", defaultValue: nil)
    var currentUserToken: String?

    @Storage(key: "currentUser_username", defaultValue: nil)
    var currentUserUsername: String?

    @Storage(key: "currentUser_email", defaultValue: nil)
    var currentUserEmail: String?

    @Storage(key: "currentUser_fullName", defaultValue: nil)
    var currentUserFullName: String?

    @Storage(key: "currentUser_biography", defaultValue: nil)
    var currentUserBiography: String?

    @Storage(key: "currentUser_coinsCount", defaultValue: 0)
    var currentUserCoinsCount: Int

    @Storage(key: "currentUser_prizesCount", defaultValue: 0)
    var currentUserPrizesCount: Int

    @Storage(key: "currentUser_votesCount", defaultValue: 0)
    var currentUserVotesCount: Int

    @Storage(key: "currentUser_followersCount", defaultValue: 0)
    var currentUserFollowersCount: Int

    @Storage(key: "currentUser_followingsCount", defaultValue: 0)
    var currentUserFollowingsCount: Int

    @Storage(key: "currentUser_voteStyleId", defaultValue: nil)
    var currentUserVoteStyleId: Int?

    @Storage(key: "currentUser_profilePhotoThumbnail", defaultValue: nil)
    var currentUserProfilePhotoThumbnail: String?

    @Storage(key: "currentUser_profilePhotoFull", defaultValue: nil)
    var currentUserProfilePhotoFull: String?

    @Storage(key: "currentUser_notificationsDeviceToken", defaultValue: nil)
    var currentUserNotificationsDeviceToken: String?

    @Storage(key: "currentUser_hasSyncedNotificationsDeviceToken", defaultValue: false)
    var currentUserHasSyncedNotificationsDeviceToken: Bool

    // MARK: - App State

    @Storage(key: "exhbt_invitation_id", defaultValue: nil)
    var exhbtInvitationId: Int?

    @Storage(key: "invitated_exhbt_id", defaultValue: nil)
    var invitedExhbtId: Int?

    @Storage(key: "appSettings_shouldUseMockData", defaultValue: false)
    var appShouldUseMockData: Bool

    @Storage(key: "shouldShowFlashAtLaunch", defaultValue: false)
    var shouldShowFlashAtLaunch: Bool

    @Storage(key: "shouldShowEventsAtLaunch", defaultValue: false)
    var shouldShowEventsAtLaunch: Bool

    // MARK: - Events

    @Storage(key: "events_showAllEvents", defaultValue: true)
    var showAllEvents: Bool

    @Storage(key: "events_sortEventsByLocation", defaultValue: false)
    var sortEventsByLocation: Bool

    @Storage(key: "events_showNSFWEvents", defaultValue: false)
    var showNSFWEvents: Bool

    // MARK: - Eligibility

    @Storage(key: "eligibility_eligibleToCreateExhbt", defaultValue: false)
    var eligibleToCreateExhbt: Bool

    @Storage(key: "eligibility_eligibleToJoinExhbt", defaultValue: false)
    var eligibleToJoinExhbt: Bool

    @Storage(key: "eligibility_eligibleToCreateEvent", defaultValue: false)
    var eligibleToCreateEvent: Bool

    @Storage(key: "eligibility_eligibleToJoinEvent", defaultValue: false)
    var eligibleToJoinEvent: Bool

    @Storage(key: "eligibility_eligibleToPostEvent", defaultValue: false)
    var eligibleToPostEvent: Bool

    @Storage(key: "currentLocation_longitude", defaultValue: nil)
    var currentLocationLongitude: Double?

    @Storage(key: "currentLocation_latitude", defaultValue: nil)
    var currentLocationLatitude: Double?

    // MARK: - Durations

    @Storage(key: "exhbt_submissionDuration", defaultValue: 4)
    var exhbtSubmissionDuration: Int

    @Storage(key: "exhbt_liveDuration", defaultValue: 1)
    var exhbtLiveDuration: Int
}
