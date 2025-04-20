//
//  ExhbtModel.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 11/06/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import Foundation

class ExhbtCloudModel {
    let id: Int
    let tags: [String]
    let createdAt: Date
    let expiresAt: Date
    let status: ExhbtStatus
    private(set) var competitions: [CompetitionModel]

    init(id: Int,
         tags: [String],
         createdAt: Date,
         expiresAt: Date,
         status: String,
         competitions: [CompetitionModel]

    ) {
        self.id = id
        self.tags = tags
        self.createdAt = createdAt
        self.expiresAt = expiresAt
        self.status = ExhbtStatus(fromString: status) ?? .archived
        self.competitions = competitions
    }

    private init() {
        id = -1
        tags = []
        createdAt = Date()
        expiresAt = Date()
        status = .finished
        competitions = []
    }

    func getVotedStatus(forUser userId: Int) -> Bool {
        !competitions
            .filter { $0.getVotedStatus(forUser: userId) }
            .isEmpty
    }

    func getCanVoteStatus(forUser userId: Int) -> Bool {
        !getVotedStatus(forUser: userId)
    }

    var voteCount: Int {
        competitions.map { $0.voteCount }.reduce(0, +)
    }

    var mediumImages: [String] {
        competitions
            .map { $0.media.url }
            .compactMap { $0 }
    }

    static let empty = ExhbtCloudModel()
}

class CompetitionModel {
    let id: Int
    let media: MediaDisplayModel
    private(set) var votes: [CompetitionVoteDisplayModel]
    private(set) var votesData: [Int: VoteStyle] = [:] // Storing votes as userId, voteStyle key-value pairs for search optimizations

    init(id: Int,
         media: MediaDisplayModel,
         votes: [CompetitionVoteDisplayModel]) {
        self.id = id
        self.media = media
        self.votes = votes

//        votes.forEach { votesData[$0.userId] = $0.style }
    }

    var voteStyles: Set<VoteStyle> {
        Set(votesData.values)
    }

    var voteCount: Int {
        votes.count
    }

    func getVotedStatus(forUser userId: Int) -> Bool {
        votesData[userId] != nil
    }
}

