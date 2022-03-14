//
//  User.swift
//  Exhbt
//
//  Created by Shouvik Paul on 4/12/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import Foundation

enum UserField: String {
    case userID
    case name
    case email
    case avatarImageUrl
    case bio
    case privateProfile
    case images
    case currentCompetitionIDs
    case wins
    case losses
    
    case coins
    case allCategoryCoins
    case architectureCoins
    case foodCoins
    case artCoins
    case natureCoins
    case sportsCoins
    case beautyCoins
    case fitnessCoins
    case autoCoins
    case fashionCoins
    case animalsCoins
    case lastDailyCoins
}

class User {
    var userID: String
    var name: String?
    var email: String?
    var avatarImageUrl: String?
    var bio: String?
    var privateProfile: Bool
    var images: [String]
    var currentCompetitionIDs: [String]
    var wins: Int
    var losses: Int
    
    var coins: Int
    var allCategoryCoins: Int
    var architectureCoins: Int
    var foodCoins: Int
    var artCoins: Int
    var natureCoins: Int
    var sportsCoins: Int
    var beautyCoins: Int
    var fitnessCoins: Int
    var autoCoins: Int
    var fashionCoins: Int
    var animalsCoins: Int
    var lastDailyCoins: String
    
    var currentCompetitions: [CompetitionDataModel] = []
    
    var selected: Bool = false
    
    init?(from dict: [String: Any]) {
        guard let userID = dict[UserField.userID.rawValue] as? String else { return nil }
        self.userID = userID
        self.name = dict[UserField.name.rawValue] as? String
        self.email = dict[UserField.email.rawValue] as? String
        self.avatarImageUrl = dict[UserField.avatarImageUrl.rawValue] as? String
        self.bio = dict[UserField.bio.rawValue] as? String
        self.privateProfile = dict[UserField.privateProfile.rawValue] as? Bool ?? false
        self.images = dict[UserField.images.rawValue] as? [String] ?? []
        self.currentCompetitionIDs = dict[UserField.currentCompetitionIDs.rawValue] as? [String] ?? []
        self.wins = dict[UserField.wins.rawValue] as? Int ?? 0
        self.losses = dict[UserField.losses.rawValue] as? Int ?? 0
        
        self.coins = dict[UserField.coins.rawValue] as? Int ?? 0
        self.allCategoryCoins = dict[UserField.allCategoryCoins.rawValue] as? Int ?? 0
        self.architectureCoins = dict[UserField.architectureCoins.rawValue] as? Int ?? 0
        self.foodCoins = dict[UserField.foodCoins.rawValue] as? Int ?? 0
        self.artCoins = dict[UserField.artCoins.rawValue] as? Int ?? 0
        self.natureCoins = dict[UserField.natureCoins.rawValue] as? Int ?? 0
        self.sportsCoins = dict[UserField.sportsCoins.rawValue] as? Int ?? 0
        self.beautyCoins = dict[UserField.beautyCoins.rawValue] as? Int ?? 0
        self.fitnessCoins = dict[UserField.fitnessCoins.rawValue] as? Int ?? 0
        self.autoCoins = dict[UserField.autoCoins.rawValue] as? Int ?? 0
        self.fashionCoins = dict[UserField.fashionCoins.rawValue] as? Int ?? 0
        self.animalsCoins = dict[UserField.animalsCoins.rawValue] as? Int ?? 0
        self.lastDailyCoins = dict[UserField.lastDailyCoins.rawValue] as? String ?? Utilities.getCurrentDateString()
        
    }
    
    convenience init(user: User) {
        self.init(
            userID: user.userID,
            name: user.name,
            email: user.email,
            avatarImageUrl: user.avatarImageUrl,
            bio: user.bio,
            privateProfile: user.privateProfile,
            images: user.images,
            currentCompetitionIDs: user.currentCompetitionIDs,
            wins: user.wins,
            losses: user.losses,
            coins: user.coins,
            allCategoryCoins: user.allCategoryCoins,
            architectureCoins: user.architectureCoins,
            foodCoins: user.foodCoins,
            artCoins: user.artCoins,
            natureCoins: user.natureCoins,
            sportsCoins: user.sportsCoins,
            beautyCoins: user.beautyCoins,
            fitnessCoins: user.fitnessCoins,
            autoCoins: user.autoCoins,
            fashionCoins: user.fashionCoins,
            animalsCoins: user.animalsCoins,
            lastDailyCoins: user.lastDailyCoins
        )
    }
    
    init(
        userID: String,
        name: String? = nil,
        email: String? = nil,
        avatarImageUrl: String? = nil,
        bio: String? = nil,
        privateProfile: Bool = false,
        images: [String] = [],
        currentCompetitionIDs: [String] = [],
        wins: Int = 0,
        losses: Int = 0,
        coins: Int = 0,
        allCategoryCoins: Int = 0,
        architectureCoins: Int = 0,
        foodCoins: Int = 0,
        artCoins: Int = 0,
        natureCoins: Int = 0,
        sportsCoins: Int = 0,
        beautyCoins: Int = 0,
        fitnessCoins: Int = 0,
        autoCoins: Int = 0,
        fashionCoins: Int = 0,
        animalsCoins: Int = 0,
        lastDailyCoins: String = Utilities.getCurrentDateString()
    ) {
        self.userID = userID
        self.name = name
        self.email = email
        self.avatarImageUrl = avatarImageUrl
        self.bio = bio
        self.privateProfile = privateProfile
        self.images = images
        self.currentCompetitionIDs = currentCompetitionIDs
        self.wins = wins
        self.losses = losses
        
        self.coins = coins
        self.allCategoryCoins = allCategoryCoins
        self.architectureCoins = architectureCoins
        self.foodCoins = foodCoins
        self.artCoins = artCoins
        self.natureCoins = natureCoins
        self.sportsCoins = sportsCoins
        self.beautyCoins = beautyCoins
        self.fitnessCoins = fitnessCoins
        self.autoCoins = autoCoins
        self.fashionCoins = fashionCoins
        self.animalsCoins = animalsCoins
        self.lastDailyCoins = lastDailyCoins
    }
    
    func toDict() -> [String: Any] {
        return [
            UserField.userID.rawValue: userID,
            UserField.name.rawValue: name ?? "",
            UserField.email.rawValue: email ?? "",
            UserField.avatarImageUrl.rawValue: avatarImageUrl ?? "",
            UserField.bio.rawValue: bio ?? "",
            UserField.privateProfile.rawValue: privateProfile,
            UserField.images.rawValue: images,
            UserField.currentCompetitionIDs.rawValue: currentCompetitionIDs,
            UserField.wins.rawValue: wins,
            UserField.losses.rawValue: losses,
            UserField.coins.rawValue: coins,
            UserField.allCategoryCoins.rawValue: allCategoryCoins,
            UserField.architectureCoins.rawValue: architectureCoins,
            UserField.foodCoins.rawValue: foodCoins,
            UserField.artCoins.rawValue: artCoins,
            UserField.natureCoins.rawValue: natureCoins,
            UserField.sportsCoins.rawValue: sportsCoins,
            UserField.beautyCoins.rawValue: beautyCoins,
            UserField.fitnessCoins.rawValue: fitnessCoins,
            UserField.autoCoins.rawValue: autoCoins,
            UserField.fashionCoins.rawValue: fashionCoins,
            UserField.animalsCoins.rawValue: animalsCoins,
            UserField.lastDailyCoins.rawValue: lastDailyCoins
        ]
    }
    
    func merge(with user: User) -> User {
        self.name = user.name
        self.bio = user.bio
        self.avatarImageUrl = user.avatarImageUrl
        self.coins = user.coins
        self.lastDailyCoins = user.lastDailyCoins
        return self
    }
    
    func shouldDisplayDailyModal() -> Bool {
        guard let date = Utilities.dateFormatter.date(from: self.lastDailyCoins) else {
            print("error formatting date: \(lastDailyCoins  )")
            return false
        }
        let interval = Date().timeIntervalSince(date)
        let hour = interval / 3600
        if Int(hour) > 24 {
            return true
        } else {
            return false
        }
    }
}
