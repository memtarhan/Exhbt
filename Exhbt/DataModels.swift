//
//  DataModels.swift
//  Exhbt
//
//  Created by Steven Worrall on 4/8/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import UIKit

enum ChallengeCategories: String, CaseIterable {
    case All
    case Architecture
    case Food
    case Art
    case Nature
    case Sports
    case Beauty
    case Fitness
    case Auto
    case Fashion
    case Animals
    
    func getCoinField() -> UserField {
        switch self {
        case .All:
            return .allCategoryCoins
        case .Architecture:
            return .architectureCoins
        case .Food:
            return .foodCoins
        case .Art:
            return .artCoins
        case .Nature:
            return .natureCoins
        case .Sports:
            return .sportsCoins
        case .Beauty:
            return .beautyCoins
        case .Fitness:
            return .fitnessCoins
        case .Auto:
            return .autoCoins
        case .Fashion:
            return .fashionCoins
        case .Animals:
            return .animalsCoins
        }
    }
}

enum CompetitionFields: String {
    case competitionID
    case creatorID
    case category
    case createdAt
    case liveAt
    case images
    case state
}

enum CompetitionState: String {
    case setup
    case live
    case expired
}

class CompetitionDataModel {
    var competitionID: String
    var creatorID: String
    var category: String
    var challengeImages: [CompetitionImage] = []
    var createdAt: String
    var liveAt: String?
    var state: CompetitionState
    var createdDate: Date {
        return Utilities.dateFormatter.date(from: createdAt) ?? Date(timeIntervalSince1970: 0)
    }
    var liveAtDate: Date? {
        guard let liveAt = liveAt else { return nil }
        return Utilities.dateFormatter.date(from: liveAt)
    }
    
    var creator: User?
    
    init?(from dict: [String: Any]) {
        guard let competitionID = dict[CompetitionFields.competitionID.rawValue] as? String,
            let creatorID = dict[CompetitionFields.creatorID.rawValue] as? String,
            let category = dict[CompetitionFields.category.rawValue] as? String,
            let createdAt = dict[CompetitionFields.createdAt.rawValue] as? String,
            let stateStr = dict[CompetitionFields.state.rawValue] as? String,
            let state = CompetitionState(rawValue: stateStr) else { return nil }
        
        self.competitionID = competitionID
        self.creatorID = creatorID
        self.category = category
        self.createdAt = createdAt
        let liveAtDate = dict[CompetitionFields.liveAt.rawValue] as? String
        if let liveAtDate = liveAtDate, liveAtDate != "" {
            self.liveAt = liveAtDate
        }
        self.state = state
        if let images = dict[CompetitionFields.images.rawValue] as? [[String: Any]] {
            for imageDict in images {
                if let image = CompetitionImage(from: imageDict) {
                    challengeImages.append(image)
                }
            }
        }
    }
    
    init(competitionID: String, creatorID: String, category: String) {
        self.competitionID = competitionID
        self.creatorID = creatorID
        self.category = category
        
        createdAt = Utilities.getCurrentDateString()
        state = .setup
    }
    
    func toDict() -> [String: Any] {
        return [
            CompetitionFields.competitionID.rawValue: competitionID,
            CompetitionFields.creatorID.rawValue: creatorID,
            CompetitionFields.category.rawValue: category,
            CompetitionFields.createdAt.rawValue: createdAt,
            CompetitionFields.liveAt.rawValue: liveAt ?? "",
            CompetitionFields.state.rawValue: state.rawValue,
            CompetitionFields.images.rawValue: challengeImages.map { return $0.toDict() }
        ]
    }
    
    func updateWithVote(images: Set<String>) {
        for i in 0...self.challengeImages.count - 1 {
            if let userId = UserManager.shared.user?.userID,
            images.contains(self.challengeImages[i].imageID) {
                self.challengeImages[i].voters.append(userId)
                self.challengeImages[i].votes += 1
            }
        }
    }

    func getTimeRemaining() -> String? {
        guard let date = liveAtDate else {
            let liveStr = liveAt ?? "nil"
            print("error formatting date: \(liveStr  )")
            return nil
        }

        let interval = Date().timeIntervalSince(date)
        let hour = interval / 3600
        let minute = interval.truncatingRemainder(dividingBy: 3600) / 60
        if Int(hour) < 1 {
            return "\(Int(minute)) minutes ago"
        }
        return "\(Int(hour)) hours ago"
    }
    
    func getTotalVotes() -> Int {
        var totalVotes = 0
        for image in self.challengeImages {
            totalVotes += image.voters.count
        }
        return totalVotes
    }
    
    func didUserVote() -> Bool {
        guard let userID = UserManager.shared.user?.userID else {
            return true
        }
        for image in challengeImages {
            if image.voters.contains(userID) {
                return true
            }
        }
        return false
    }
}

enum CompetitionImageFields: String {
    case imageID
    case userID
    case votes
    case voters
}

struct CompetitionImage {
    var imageID: String
    var userID: String
    var votes: Int = 0
    var voters: [String] = []
    
    var fromGallery: Bool = false
    var image: UIImage?
    var url: URL?
    
    init?(from dict: [String: Any]) {
        guard let imageID = dict[CompetitionImageFields.imageID.rawValue] as? String,
            let userID = dict[CompetitionImageFields.userID.rawValue] as? String else {
                return nil
        }
        self.imageID = imageID
        self.userID = userID
        self.votes = dict[CompetitionImageFields.votes.rawValue] as? Int ?? 0
        self.voters = dict[CompetitionImageFields.voters.rawValue] as? [String] ?? []
    }
    
    init(imageID: String, userID: String, fromGallery: Bool, image: UIImage) {
        self.imageID = imageID
        self.userID = userID
        self.fromGallery = fromGallery
        self.image = image
    }
    
    func toDict() -> [String: Any] {
        return [
            CompetitionImageFields.imageID.rawValue: imageID,
            CompetitionImageFields.userID.rawValue: userID,
            CompetitionImageFields.votes.rawValue: votes,
            CompetitionImageFields.voters.rawValue: voters
        ]
    }
}
