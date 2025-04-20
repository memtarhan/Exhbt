//
//  Response.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 22/12/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import Foundation

// TODO: Sort it by name
protocol APIResponse: Codable { }

// MARK: - Competition

/// - CompetitionPhotosResponse
struct CompetitionPhotosResponse: APIResponse {
    let regular: String
    let medium: String
    let thumbnail: String
}

/// - CompetitionResponse
struct CompetitionResponse: APIResponse {
    let id: Int
    let exhbtId: Int
    let competitorId: Int
    let createdDate: Date
    let media: ContentResponse?
    let voted: Bool
    let votes: [CompetitionVoteResponse]
}

/// - NewCompetitionResponse
struct NewCompetitionResponse: APIResponse {
    let competition: CompetitionResponse
    let coinsCount: Int
}

/// - CompetitionVoteResponse
struct CompetitionVoteResponse: APIResponse {
    let styleId: Int
    let userId: Int
}

// MARK: - Events

/// - EventsResponse
struct EventsResponse: APIResponse {
    let items: [EventResponse]
}

/// -  EventResponse
struct EventResponse: APIResponse {
    let id: Int
    let title: String
    let description: String
    let isOwn: Bool
    let nsfw: Bool
    let joined: Bool
    let creatorId: Int
    let createdDate: Date
    let startDate: Date?
    let expirationDate: Date?
    let coverPhoto: String?
    let status: EventStatusType
    let joiners: EventJoinersResponse
    let photos: [String]
}

/// - NewEventResponse
struct NewEventResponse: APIResponse {
    let event: EventResponse
    let coinsCount: Int
}

/// - EventJoinersResponse
struct EventJoinersResponse: APIResponse {
    let title: String
    let users: [EventJoinerResponse]
}

/// - EventJoinerResponse
struct EventJoinerResponse: APIResponse {
    let id: Int
    let photoUrl: String?
}

/// - EventStatusType
enum EventStatusType: String, APIResponse {
    case live
    case finished
}

/// -  EventResultRankResponse
struct EventResultRankResponse: APIResponse {
    let username: String?
    let userId: Int
    let profilePhoto: String?
    let rank: Int
    let popularity: Int
}

/// -  EventResultDataResponse
struct EventResultDataResponse: APIResponse {
    let title: String?
    let description: String?
    let media: ContentResponse?
    let ranks: [EventResultRankResponse]
    let winner: WinnerResponse
}

/// -  EventResultResponse
struct EventResultResponse: APIResponse {
    let id: Int
    let createdDate: Date
    let creatorId: Int
    let eventId: Int
    let data: EventResultDataResponse
}

// MARK: - Exhbts

/// - ExhbtPreviewResponse
struct ExhbtPreviewResponse: APIResponse {
    let id: Int
    let tags: [String]
    let description: String
    let dates: FeedPreviewDatesResponse
    let media: [ContentResponse]
    let status: ExhbtStatusTypeResponse
    let type: ExhbtTypeResponse
    let isOwn: Bool
}

/// - ExhbtsPreviewResponse
struct ExhbtsPreviewResponse: APIResponse {
    let items: [ExhbtPreviewResponse]
}

/// - ExhbtResponse
struct ExhbtResponse: APIResponse {
    let id: Int
    let canVote: Bool
    let createdDate: Date
    let startDate: Date?
    let expirationDate: Date?
    let status: String
    let tags: [String]
    let type: ExhbtTypeResponse
    let competitions: [CompetitionResponse]
}

/// - NewExhbtResponse
struct NewExhbtResponse: APIResponse {
    let exhbt: ExhbtResponse
    let coinsCount: Int
}

/// - ContentVideoResponse
struct ContentVideoResponse: APIResponse {
    let url: String
    let thumbnail: String
}

/// - ContentPhotoResponse
struct ContentPhotoResponse: APIResponse {
    let thumbnail: String
    let small: String
    let medium: String
    let large: String
    let full: String
}

/// - ExhbtMediaResponse
struct ContentResponse: APIResponse {
    let video: ContentVideoResponse?
    let photo: ContentPhotoResponse?
    let mediaType: MediaTypeResponse
    let aspectRatio: Double
}

/// - ExhbtStatusResponse
struct ExhbtStatusResponse: APIResponse {
    let name: String
    let id: Int
}

/// - ExhbtStatusTypeResponse
enum ExhbtStatusTypeResponse: String, APIResponse {
    case submissions
    case live
    case finished
    case archived
}

/// - ExhbtTypeResponse
enum ExhbtTypeResponse: String, APIResponse {
    case `public`
    case `private`
}

/// - ExhbtFlagResponse
struct ExhbtFlagResponse: APIResponse {
    let id: Int
    let creatorId: Int
    let exhbtId: Int
    let createdDate: Date
}

/// - ExhbtDetailsResponse
struct ExhbtDetailsResponse: APIResponse {
    let id: Int
    let description: String
    let reachedCompetitionLimit: Bool
    let canEdit: Bool
    let canJoin: Bool
    let isOwn: Bool
    let type: ExhbtTypeResponse
    let preview: ExhbtDetailsPreviewResponse
    let status: ExhbtDetailsStatusResponse
    let competitors: ExhbtDetailsCompetitorsResponse
    let submissions: ExhbtDetailsSubmissionsResponse
}

/// - ExhbtDetailsPreviewResponse
struct ExhbtDetailsPreviewResponse: APIResponse {
    let tags: [String]
    let media: [ContentResponse]
}

/// - ExhbtDetailsStatusResponse
struct ExhbtDetailsStatusResponse: APIResponse {
    let status: ExhbtStatusTypeResponse
    let createdDate: Date
    let startDate: Date
    let expirationDate: Date?
    let remainingCompetitorsCount: Int
}

/// - ExhbtDetailsCompetitorResponse
struct ExhbtDetailsCompetitorResponse: APIResponse {
    let id: Int?
    let photo: String?
    let name: String?
    let isExhbtUser: Bool
}

/// - ExhbtDetailsStatusResponse
struct ExhbtDetailsCompetitorsResponse: APIResponse {
    let title: String
    let countDescription: String
    let pending: [ExhbtDetailsCompetitorResponse]
    let accepted: [ExhbtDetailsCompetitorResponse]
    let freeSpots: Int
}

/// - ExhbtDetailsSubmissionResponse
struct ExhbtDetailsSubmissionResponse: APIResponse {
    let photo: String
    let voteCount: Int
}

/// - ExhbtDetailsSubmissionsResponse
struct ExhbtDetailsSubmissionsResponse: APIResponse {
    let title: String
    let countDescription: String
    let isLocked: Bool
    let submissions: [ExhbtDetailsSubmissionResponse]
}

/// - ExhbtResultDataResponse
struct ExhbtResultDataResponse: APIResponse {
    let tags: [String]
    let media: [ContentResponse]
    let description: String
    let topRankCompetitors: [ExhbtResultCompetitorResponse]
    let bottomRankCompetitors: [ExhbtResultCompetitorResponse]
    let winner: WinnerResponse
}

/// - ExhbtResultResponse
struct ExhbtResultResponse: APIResponse {
    let id: Int
    let exhbtId: Int
    let creatorId: Int
    let createdDate: Date
    let data: ExhbtResultDataResponse
}

/// - ExhbtResultWholeResponse
struct ExhbtResultWholeResponse: APIResponse {
    let result: ExhbtResultResponse
    let canView: Bool
}

/// - ExhbtResultCompetitorResponse
struct ExhbtResultCompetitorResponse: APIResponse {
    let id: Int
    let profilePhoto: String?
    let username: String?
    let rank: Int
    let score: Int
}

// MARK: - FeedsPreviewResponse

struct FeedsPreviewResponse: APIResponse {
    let items: [FeedPreviewResponse]
}

// MARK: - FeedPreviewDatesResponse

struct FeedPreviewDatesResponse: APIResponse {
    let createdDate: Date
    let startDate: Date
    let expirationDate: Date?
}

// MARK: - FeedPreviewResponse

struct FeedPreviewResponse: APIResponse {
    let id: Int
    let description: String
    let dates: FeedPreviewDatesResponse
    let tags: [String]
    let media: [ContentResponse]
    let voteCount: Int
    let voted: Bool
}

// MARK: - FlashPreviewsResponse

struct FlashPreviewsResponse: APIResponse {
    let items: [FlashPreviewResponse]
    let coinsCount: Int
}

// MARK: - FlashPreviewResponse

struct FlashPreviewResponse: APIResponse {
    let id: Int
    let media: ContentResponse
}

// MARK: - FlashInteractResponse

struct FlashInteractResponse: APIResponse {
    let competitionId: Int
    let result: FlashInteractResultResponse
    let coinsCount: Int
}

// MARK: - FlashInteractResultResponse

enum FlashInteractResultResponse: String, APIResponse {
    case win
    case lose
}

// MARK: - FeedResponse

struct FeedResponse: APIResponse {
    let id: Int
    let creatorId: Int
    let tags: [String]
    let createdDate: Date
    let expirationDate: Date?
    let photos: [String]
    let thumbnails: [String]
    let voteCount: Int
    let voted: Bool
    let status: ExhbtStatusTypeResponse
    let canEdit: Bool
}

// MARK: - FeedsResponse

struct FeedsResponse: APIResponse {
    let items: [FeedResponse]
}

// MARK: - FollowersResponse

struct FollowersResponse: APIResponse {
    let items: [FollowerResponse]
    let followersCount: Int
    let followingsCount: Int
}

// MARK: - FollowerResponse

struct FollowerResponse: APIResponse {
    let id: Int
    let profilePhoto: String?
    let username: String
    let following: Bool
    let isMe: Bool
}

// MARK: - InvitationsResponse

struct InvitationsResponse: APIResponse {
    let items: [InvitationResponse]
}

// MARK: - InvitationResponse

struct InvitationResponse: APIResponse {
    let id: Int
    let exhbtId: Int
    let link: String?
    let invitedUserId: Int?
    let status: InvitationStatusType
}

// MARK: - EventInvitationResponse

struct EventInvitationResponse: APIResponse {
    let id: Int
    let eventId: Int
    let link: String?
    let invitedUserId: Int?
    let status: InvitationStatusType
}

struct EventInvitationsResponse: APIResponse {
    let items: [EventInvitationResponse]
}

// MARK: - InvitedUserResponse

struct InvitedUserResponse: APIResponse {
    let photo: String?
    let name: String?
}

// MARK: - InvitationStatusType

enum InvitationStatusType: String, APIResponse {
    case pending
    case accepted
    case share
    case invalidPhone
}

// MARK: - LeaderboardUserResponse

struct LeaderboardUserResponse: APIResponse {
    let id: Int
    let rank: RankResponse
    let profilePhoto: String?
    let username: String?
    let score: Int
}

// MARK: - LeaderboardResponse

struct LeaderboardResponse: APIResponse {
    let items: [LeaderboardUserResponse]
}

// MARK: - Media

/// - MediaTypeResponse
enum MediaTypeResponse: String, APIResponse {
    case image
    case video
}

// MARK: - RankResponse

struct RankResponse: APIResponse {
    let number: Int
    let type: RankType
}

// MARK: - RankType

enum RankType: String, APIResponse {
    case gold
    case silver
    case bronze
    case regular

    var colorName: String {
        "RankType_\(rawValue.capitalized)"
    }

    var hasWhiteText: Bool {
        switch self {
        case .gold, .silver, .bronze: return true
        default: return false
        }
    }

    var displayNumber: String? {
        switch self {
        case .gold:
            return "1"
        case .silver:
            return "2"
        case .bronze:
            return "3"
        case .regular:
            return nil
        }
    }

    init?(fromId id: Int) {
        switch id {
        case 0:
            self = .gold
        case 1:
            self = .silver
        case 2:
            self = .bronze
        default:
            return nil
        }
    }
}

// MARK: - NotificationResponse

struct NotificationResponse: APIResponse {
    let id: Int
    let isRead: Bool
    let type: NotificationType
    let createdDate: Date
    let photoUrl: String?
    let text: String?
    let userId: Int?
    let exhbtId: Int?
    let eventId: Int?
}

// MARK: - NotificationsResponse

struct NotificationsResponse: APIResponse {
    let items: [NotificationResponse]
}

// MARK: - NotificationUserResponse

struct NotificationUserResponse: APIResponse {
    let name: String?
    let photo: String?
}

struct NotificationExhbtResponse: APIResponse {
    let title: String?
    let photo: String?
}

struct NotificationsBadgeCountResponse: APIResponse {
    let count: Int
}

struct PostsResponse: APIResponse {
    let items: [PostResponse]
}

// MARK: - PostResponse

struct PostResponse: APIResponse {
    let id: Int
    let userId: Int
    let isOwn: Bool
    let eventId: Int
    let createdDate: Date
    let media: ContentResponse?
    let likesCount: Int
    let dislikesCount: Int
    let interaction: InteractionResponse?
}

// MARK: - UploadResponse

struct UploadResponse: APIResponse {
    let url: String
}

// MARK: - UserResponse

struct UserResponse: APIResponse {
    let id: Int
    let username: String?
    let fullName: String?
    let email: String?
    let biography: String?
    let following: Bool
    let coinsCount: Int
    let prizesCount: Int
    let votesCount: Int
    let followersCount: Int
    let followingCount: Int
    let voteStyle: VoteStyleResponse?
    let media: ContentResponse?
    let missingDetails: Bool
}

struct UsernameUpdateResponse: APIResponse {
    let updated: Bool
    let response: String?
}

// MARK: - UserPhotosResponse

struct UserPhotosResponse: APIResponse {
    let profileThumbnail: String?
    let profileFull: String?
    let coverThumbnail: String?
    let coverFull: String?
}

// MARK: - UserTokenResponse

struct UserTokenResponse: APIResponse {
    let userId: Int
    let accessToken: String
    let tokenType: String
    let missingDetails: Bool
}

struct NotificationsDeviceTokenResponse: APIResponse {
    let token: String?
}

// MARK: - VoteStyleResponse

struct VoteStyleResponse: APIResponse {
    let id: Int
}

// MARK: - VoteAddResponse

struct VoteAddResponse: APIResponse {
    let id: Int
}

// MARK: - VoteRemoveResponse

struct VoteRemoveResponse: APIResponse {
    let id: Int
}

// MARK: LinkResponse

struct LinkResponse: APIResponse {
    let link: String
}

// MARK: - UserSubmissionsResponse

struct UserSubmissionsResponse: APIResponse {
    let items: [UserSubmissionResponse]
}

// MARK: - UserSubmissionResponse

struct UserSubmissionResponse: APIResponse {
    let competitionId: Int
    let media: ContentResponse
}

// MARK: - UserEligibilityResponse

struct UserEligibilityResponse: APIResponse {
    let eligibleToCreateExhbt: Bool
    let eligibleToJoinExhbt: Bool
    let eligibleToCreateEvent: Bool
    let eligibleToJoinEvent: Bool
    let eligibleToPostEvent: Bool
    let coinsCount: Int
    let exhbtSubmissionDuration: Int
    let exhbtLiveDuration: Int
}

// MARK: - ExploreSearchUserResponse

struct ExploreSearchUserResponse: APIResponse {
    let items: [ExploreUserResponse]
}

// MARK: - ExploreUser

struct ExploreUserResponse: APIResponse {
    let id: Int
    let username, fullName: String
    let profilePhoto: String?
}

// MARK: - TagsResponse

struct TagsResponse: APIResponse {
    let items: [TagResponse]
}

// MARK: - Tag Response

struct TagResponse: APIResponse {
    let id: Int
    let label: String
    let exhbtsCount: Int
}

struct UserTagResponse: APIResponse {
    let id: Int
    let label: String
}

struct UserTagsResponse: APIResponse {
    let items: [UserTagResponse]
}

struct WinnerResponse: APIResponse {
    let backgroundImage: String
    let profileImage: String?
    let username: String?
}

enum MedalType: String, APIResponse {
    case gold
    case silver
    case bronze

    var imageName: String {
        "prize_\(rawValue)"
    }
}

struct PrizeResponse: APIResponse {
    let id: Int
    let exhbtId: Int
    let winnerId: Int
    let points: Int
    let type: MedalType
}

struct PrizesResponse: APIResponse {
    let items: [PrizeResponse]
}
