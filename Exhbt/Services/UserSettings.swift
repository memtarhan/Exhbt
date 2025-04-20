//
//  UserSettings.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 07/07/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import Foundation

class UserSettings {
    static let shared = UserSettings()

    var signedIn: Bool {
        LocalStorage.shared.currentUserToken != nil
    }

    var id: Int {
        get {
            guard let userId = LocalStorage.shared.currentUserId else {
                // TODO: Change to Splash screen if possib;e
                fatalError("No user id found")
            }
            return userId
        }
        set { LocalStorage.shared.currentUserId = newValue }
    }

    var token: String? {
        get { LocalStorage.shared.currentUserToken }
        set { LocalStorage.shared.currentUserToken = newValue }
    }

    var username: String? {
        get { LocalStorage.shared.currentUserUsername }
        set { LocalStorage.shared.currentUserUsername = newValue }
    }

    var email: String? {
        get { LocalStorage.shared.currentUserEmail }
        set { LocalStorage.shared.currentUserEmail = newValue }
    }

    var fullName: String? {
        get { LocalStorage.shared.currentUserFullName }
        set { LocalStorage.shared.currentUserFullName = newValue }
    }

    var biography: String? {
        get { LocalStorage.shared.currentUserBiography }
        set { LocalStorage.shared.currentUserBiography = newValue }
    }

    var coinsCount: Int {
        get { LocalStorage.shared.currentUserCoinsCount }
        set { LocalStorage.shared.currentUserCoinsCount = newValue }
    }

    var prizesCount: Int {
        get { LocalStorage.shared.currentUserPrizesCount }
        set { LocalStorage.shared.currentUserPrizesCount = newValue }
    }

    var votesCount: Int {
        get { LocalStorage.shared.currentUserVotesCount }
        set { LocalStorage.shared.currentUserVotesCount = newValue }
    }

    var followersCount: Int {
        get { LocalStorage.shared.currentUserFollowersCount }
        set { LocalStorage.shared.currentUserFollowersCount = newValue }
    }

    var followingsCount: Int {
        get { LocalStorage.shared.currentUserFollowingsCount }
        set { LocalStorage.shared.currentUserFollowingsCount = newValue }
    }

    var voteStyle: VoteStyle? {
        get {
            if let id = LocalStorage.shared.currentUserVoteStyleId {
                return VoteStyle(rawValue: id)
            }
            return nil

        } set {
            LocalStorage.shared.currentUserVoteStyleId = newValue?.id
        }
    }

    var profilePhotoThumbnail: String? {
        get { LocalStorage.shared.currentUserProfilePhotoThumbnail }
        set { LocalStorage.shared.currentUserProfilePhotoThumbnail = newValue }
    }

    var profilePhotoFull: String? {
        get { LocalStorage.shared.currentUserProfilePhotoFull }
        set { LocalStorage.shared.currentUserProfilePhotoFull = newValue }
    }

    var notificationsDeviceToken: String? {
        get { LocalStorage.shared.currentUserNotificationsDeviceToken }
        set { LocalStorage.shared.currentUserNotificationsDeviceToken = newValue }
    }

    var hasSyncedNotificationsDeviceToken: Bool {
        get { LocalStorage.shared.currentUserHasSyncedNotificationsDeviceToken }
        set { LocalStorage.shared.currentUserHasSyncedNotificationsDeviceToken = newValue }
    }

    var shouldShowFlashAtLaunch: Bool {
        get { LocalStorage.shared.shouldShowFlashAtLaunch }
        set { LocalStorage.shared.shouldShowFlashAtLaunch = newValue }
    }

    var shouldShowEventsAtLaunch: Bool {
        get { LocalStorage.shared.shouldShowEventsAtLaunch }
        set { LocalStorage.shared.shouldShowEventsAtLaunch = newValue }
    }

    var eligibleToCreateExhbt: Bool {
        get { LocalStorage.shared.eligibleToCreateExhbt }
        set { LocalStorage.shared.eligibleToCreateExhbt = newValue }
    }

    var eligibleToJoinExhbt: Bool {
        get { LocalStorage.shared.eligibleToJoinExhbt }
        set { LocalStorage.shared.eligibleToJoinExhbt = newValue }
    }

    var eligibleToCreateEvent: Bool {
        get { LocalStorage.shared.eligibleToCreateEvent }
        set { LocalStorage.shared.eligibleToCreateEvent = newValue }
    }

    var eligibleToJoinEvent: Bool {
        get { LocalStorage.shared.eligibleToJoinEvent }
        set { LocalStorage.shared.eligibleToJoinEvent = newValue }
    }

    var eligibleToPostEvent: Bool {
        get { LocalStorage.shared.eligibleToPostEvent }
        set { LocalStorage.shared.eligibleToPostEvent = newValue }
    }

    var currentLocation: CurrentLocation? {
        get {
            guard let longitude = LocalStorage.shared.currentLocationLongitude,
                  let latitude = LocalStorage.shared.currentLocationLatitude else { return nil }
            return CurrentLocation(longitude: longitude, latitude: latitude)
        }
        set {
            LocalStorage.shared.currentLocationLongitude = newValue?.longitude
            LocalStorage.shared.currentLocationLatitude = newValue?.latitude
        }
    }

    var exhbtSubmissionDuration: Int {
        get { LocalStorage.shared.exhbtSubmissionDuration }
        set { LocalStorage.shared.exhbtSubmissionDuration = newValue }
    }

    var exhbtLiveDuration: Int {
        get { LocalStorage.shared.exhbtLiveDuration }
        set { LocalStorage.shared.exhbtLiveDuration = newValue }
    }

    func save(eligibility: UserEligibilityResponse) {
        eligibleToCreateExhbt = eligibility.eligibleToCreateExhbt
        eligibleToJoinExhbt = eligibility.eligibleToJoinExhbt
        eligibleToCreateEvent = eligibility.eligibleToCreateEvent
        eligibleToJoinEvent = eligibility.eligibleToJoinEvent
        eligibleToPostEvent = eligibility.eligibleToPostEvent
    }

    func save(durations: UserEligibilityResponse) {
        exhbtSubmissionDuration = durations.exhbtSubmissionDuration
        exhbtLiveDuration = durations.exhbtLiveDuration
    }

    func save(response: UserResponse) {
        id = response.id
        email = response.email
        username = response.username
        fullName = response.fullName
        biography = response.biography
        coinsCount = response.coinsCount
        prizesCount = response.prizesCount
        votesCount = response.votesCount
        followersCount = response.followersCount
        followingsCount = response.followingCount
        if let style = response.voteStyle {
            voteStyle = VoteStyle(rawValue: style.id)
        }
        profilePhotoThumbnail = response.media?.photo?.thumbnail
        profilePhotoFull = response.media?.photo?.full
    }

    func clearAllUserDefaults() {
        UserDefaults.standard.dictionaryRepresentation().forEach { item in
            UserDefaults.standard.removeObject(forKey: item.key)
        }
    }
}

struct CurrentLocation {
    let longitude: Double
    let latitude: Double
}
