//
//  DisplayModels.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 12/05/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Foundation
import SwiftUI

// MARK: Please sort models by name

// MARK: DisplayModel - Root

/// Conforms to NSDiffableDataSource protocol
class DisplayModel: Hashable {
    let id: Int

    init(id: Int) {
        self.id = id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: DisplayModel, rhs: DisplayModel) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - CategoryDisplayModel

class CategoryDisplayModel: DisplayModel, Identifiable {
    let title: String
    let imageName: String
    let category: Category

    init(id: Int,
         title: String,
         imageName: String,
         category: Category) {
        self.title = title
        self.imageName = imageName
        self.category = category
        super.init(id: id)
    }
}

// MARK: - CompetitionDisplayModel

struct CompetitionContentDisplayModel {
    let videoURL: String?
    let thumbnailURL: String?
    let photoURL: String?
}

class CompetitionDisplayModel: DisplayModel {
    var voted: Bool
    private(set) var votes: [CompetitionVoteDisplayModel]
    let content: CompetitionContentDisplayModel

    init(id: Int, voted: Bool, votes: [CompetitionVoteResponse], content: ContentResponse?) {
        self.voted = voted
        self.votes = votes.map { CompetitionVoteDisplayModel(userId: $0.userId, style: VoteStyle(rawValue: $0.styleId) ?? .style1) }

        if let video = content?.video {
            self.content = CompetitionContentDisplayModel(videoURL: video.url, thumbnailURL: video.thumbnail, photoURL: nil)

        } else {
            self.content = CompetitionContentDisplayModel(videoURL: nil, thumbnailURL: content?.photo?.thumbnail, photoURL: content?.photo?.large)
        }
        super.init(id: id)
    }

    var voteStyles: [VoteStyle] {
        let styles = votes.map({ $0.style })
        let set = Set(styles)
        var array = Array(set)
        array.sort { $0.id < $1.id }
        return array
    }

    var votesCount: Int { votes.count }

    func addVote() {
        guard let voteStyle = UserSettings.shared.voteStyle else { return }
        let vote = CompetitionVoteDisplayModel(userId: UserSettings.shared.id, style: voteStyle)
        if !votes.contains(vote) {
            votes.append(vote)
        }
    }

    func removeVote() {
        guard let voteStyle = UserSettings.shared.voteStyle else { return }
        let vote = CompetitionVoteDisplayModel(userId: UserSettings.shared.id, style: voteStyle)
        votes.removeAll(where: { $0 == vote })
    }

    static func == (lhs: CompetitionDisplayModel, rhs: CompetitionDisplayModel) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - CompetitionVoteModel

struct CompetitionVoteDisplayModel: Equatable {
    let userId: Int
    let style: VoteStyle

    init(userId: Int, style: VoteStyle) {
        self.userId = userId
        self.style = style
    }
}

// MARK: - MediaDisplayModel

struct MediaDisplayModel {
    var image: UIImage? = nil
    let url: String
    let videoUrl: String?
    let mediaType: MediaTypeResponse

    static func from(response: ContentResponse) -> MediaDisplayModel {
        let videoURL = response.video?.url
        let url = response.photo?.medium ?? response.video?.thumbnail

        return MediaDisplayModel(url: url!, videoUrl: videoURL, mediaType: response.mediaType)
    }

    static var photoSample: MediaDisplayModel {
        MediaDisplayModel(url: photoURLs.randomElement()!,
                          videoUrl: nil,
                          mediaType: .image)
    }

    static let videoSample = MediaDisplayModel(url: "https://images.pexels.com/photos/3278327/pexels-photo-3278327.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",
                                               videoUrl: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
                                               mediaType: .video)

    private static let photoURLs = ["https://images.pexels.com/photos/11334332/pexels-photo-11334332.jpeg?auto=compress&cs=tinysrgb&w=800&lazy=load",
                                    "https://images.pexels.com/photos/16986836/pexels-photo-16986836/free-photo-of-illuminated-city-at-night.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",
                                    "https://images.pexels.com/photos/9720518/pexels-photo-9720518.jpeg?auto=compress&cs=tinysrgb&w=800&lazy=load",
                                    "https://images.pexels.com/photos/5684479/pexels-photo-5684479.png?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2"]
}

// MARK: - EventPostDisplayModel

class EventPostDisplayModel: DisplayModel {
    let eventId: Int
    let media: MediaDisplayModel

    init(id: Int, eventId: Int, media: MediaDisplayModel) {
        self.media = media
        self.eventId = eventId

        super.init(id: id)
    }

    static var photoSample: EventPostDisplayModel { EventPostDisplayModel(id: Int.random(in: 0 ... 100), eventId: 1, media: MediaDisplayModel.photoSample) }
    static let videoSample = EventPostDisplayModel(id: Int.random(in: 0 ... 100), eventId: 1, media: MediaDisplayModel.videoSample)
}

// MARK: - EventDisplayModel

class EventDisplayModel: DisplayModel {
    let title: String
    let description: String
    let isOwn: Bool
    let nsfw: Bool
    var joined: Bool
    let coverPhoto: String
    let photos: [String]
    var joiners: EventJoinersDisplayModel
    let timeLeft: String
    let status: EventStatusDisplayModel

    init(id: Int,
         title: String,
         description: String,
         isOwn: Bool,
         nsfw: Bool,
         joined: Bool,
         coverPhoto: String,
         photos: [String],
         joiners: EventJoinersDisplayModel,
         timeLeft: String,
         status: EventStatusDisplayModel) {
        self.title = title
        self.description = description
        self.isOwn = isOwn
        self.nsfw = nsfw
        self.joined = joined
        self.coverPhoto = coverPhoto
        self.photos = photos
        self.joiners = joiners
        self.timeLeft = timeLeft
        self.status = status

        super.init(id: id)
    }

    static func from(response: EventResponse) -> EventDisplayModel {
        return EventDisplayModel(id: response.id,
                                 title: response.title,
                                 description: response.description,
                                 isOwn: response.isOwn,
                                 nsfw: response.nsfw,
                                 joined: response.joined,
                                 coverPhoto: response.coverPhoto ?? "",
                                 photos: response.photos,
                                 joiners: EventJoinersDisplayModel(title: response.joiners.title, photos: response.joiners.users.map { $0.photoUrl ?? "" }),
                                 timeLeft: response.expirationDate?.timeLeft ?? "NaN left",
                                 status: EventStatusDisplayModel(status: EventStatus(fromType: response.status), timeLeft: response.expirationDate?.timeLeft ?? "NaN left"))
    }

    static let sample = EventDisplayModel(id: 1,
                                          title: "Dummy Event at #\(1)",
                                          description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Sed ut laborum",
                                          isOwn: Bool.random(),
                                          nsfw: Bool.random(),
                                          joined: false,
                                          coverPhoto: "https://images.pexels.com/photos/15839628/pexels-photo-15839628/free-photo-of-a-person-holding-a-coffee-cup.jpeg?auto=compress&cs=tinysrgb&w=1200&lazy=load",
                                          photos: ["https://images.pexels.com/photos/15839628/pexels-photo-15839628/free-photo-of-a-person-holding-a-coffee-cup.jpeg?auto=compress&cs=tinysrgb&w=1200&lazy=load"],
                                          joiners: EventJoinersDisplayModel(title: "+2 joined", photos: ["https://images.pexels.com/photos/11456343/pexels-photo-11456343.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2", "https://images.pexels.com/photos/19288075/pexels-photo-19288075/free-photo-of-aerial-view-of-a-church-in-the-middle-of-a-field.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",
                                                                                                         "https://images.pexels.com/photos/19248753/pexels-photo-19248753/free-photo-of-a-woman-with-a-white-tank-top-and-a-green-olive-tree.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2"]),
                                          timeLeft: "\(2)d left",
                                          status: EventStatusDisplayModel(status: .live, timeLeft: "2d left"))
}

// MARK: - ExhbtPreviewDisplayModel

class ExhbtPreviewDisplayModel: DisplayModel {
    let description: String
    let horizontalModels: [HorizontalPhotoModel]
    let expirationDate: Date
    let status: ExhbtStatus
    let isOwn: Bool

    init(id: Int,
         description: String,
         horizontalModels: [HorizontalPhotoModel],
         expirationDate: Date,
         status: ExhbtStatus,
         isOwn: Bool) {
        self.description = description
        self.horizontalModels = horizontalModels
        self.expirationDate = expirationDate
        self.status = status
        self.isOwn = isOwn

        super.init(id: id)
    }

    static func from(response: ExhbtPreviewResponse) -> ExhbtPreviewDisplayModel {
        ExhbtPreviewDisplayModel(id: response.id,
                                 description: response.description,
                                 horizontalModels: response.media.map { HorizontalPhotoModel(withResponse: $0) },
                                 expirationDate: response.status == ExhbtStatusTypeResponse.submissions ? response.dates.startDate : (response.dates.expirationDate ?? response.dates.startDate),
                                 status: ExhbtStatus(fromType: response.status),
                                 isOwn: response.isOwn)
    }
}

// MARK: - EventJoinersDisplayModel

struct EventJoinersDisplayModel {
    let title: String
    let photos: [String]
}

// MARK: - EventStatusDisplayModel

struct EventStatusDisplayModel {
    let status: EventStatus
    let timeLeft: String?
}

// MARK: - ExploreUserDisplayModel

class ExploreUserDisplayModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: ExploreUserDisplayModel, rhs: ExploreUserDisplayModel) -> Bool {
        lhs.id == rhs.id
    }

    let id: Int
    let username, fullName: String
    let profilePhoto: String?
    init(id: Int, username: String, fullName: String, profilePhoto: String?) {
        self.id = id
        self.username = "@\(username)"
        self.fullName = fullName
        self.profilePhoto = profilePhoto
    }
}

// MARK: - FeedPreviewDisplayModel

class FeedPreviewDisplayModel: DisplayModel {
    let tag: String
    let description: String
    let media: [HorizontalPhotoModel]
    var voted: Bool
    var voteCount: Int
    let timeLeft: String

    init(id: Int,
         tag: String,
         description: String,
         media: [HorizontalPhotoModel],
         voted: Bool,
         voteCount: Int,
         expirationDate: Date) {
        self.tag = tag
        self.description = description
        self.media = media
        self.voted = voted
        self.voteCount = voteCount
        timeLeft = expirationDate.timeLeft

        super.init(id: id)
    }

    init(withResponse response: FeedPreviewResponse) {
        tag = "#\(response.tags.first ?? "")"
        description = response.description
        media = response.media.map { HorizontalPhotoModel(withResponse: $0) }
        voted = response.voted
        voteCount = response.voteCount
        timeLeft = response.dates.expirationDate?.timeLeft ?? response.dates.startDate.timeLeft

        super.init(id: response.id)
    }
}

// MARK: - FlashDisplayModel

class FlashDisplayModel: DisplayModel, Identifiable {
    let index: Int
    let photoURL: URL?
    let videoURL: URL?

    init(id: Int, index: Int, url: String, videUrl: String?) {
        self.index = index
        photoURL = URL(string: url)
        if let videUrl {
            videoURL = URL(string: videUrl) // TODO: Get it from response

        } else {
            videoURL = nil
        }
        super.init(id: id)
    }
}

// MARK: - ExhbtResultTopRanksDisplayModel

class ExhbtResultTopRanksDisplayModel: DisplayModel {
    let users: [ExhbtResultTopRankUserDisplayModel]

    init(id: Int, users: [ExhbtResultTopRankUserDisplayModel]) {
        self.users = users
        super.init(id: id)
    }

    static let sample = ExhbtResultTopRanksDisplayModel(id: -1, users: [
        ExhbtResultTopRankUserDisplayModel(userId: 1,
                                           rankType: .gold,
                                           photoURL: "https://res.cloudinary.com/dwkwx0jor/image/upload/c_thumb,g_faces,h_96,w_96/users/48_profile.jpg",
                                           username: "username",
                                           score: "10p"),
        ExhbtResultTopRankUserDisplayModel(userId: 2,
                                           rankType: .silver,
                                           photoURL: "https://res.cloudinary.com/dwkwx0jor/image/upload/c_thumb,g_faces,h_96,w_96/users/48_profile.jpg",
                                           username: "username",
                                           score: "5p"),
        ExhbtResultTopRankUserDisplayModel(userId: 3,
                                           rankType: .bronze,
                                           photoURL: "https://res.cloudinary.com/dwkwx0jor/image/upload/c_thumb,g_faces,h_96,w_96/users/48_profile.jpg",
                                           username: "username",
                                           score: "2p"),
    ])
}

class ExhbtResultTopRankUserDisplayModel: DisplayModel {
    let rankType: RankType
    let photoURL: String?
    let username: String?
    let score: String

    init(userId: Int, rankType: RankType, photoURL: String?, username: String?, score: String) {
        self.rankType = rankType
        self.photoURL = photoURL
        self.username = username
        self.score = score

        super.init(id: userId)
    }

    static let sample = ExhbtResultTopRankUserDisplayModel(userId: 1,
                                                           rankType: .gold,
                                                           photoURL: "https://res.cloudinary.com/dwkwx0jor/image/upload/c_thumb,g_faces,h_96,w_96/users/48_profile.jpg",
                                                           username: "username\n(you)",
                                                           score: "10p")
}

// MARK: - FollowerDisplayModel

class FollowerDisplayModel: DisplayModel {
    let username: String
    let profilePhoto: String?
    var followingStatus: FollowingStatus

    init(id: Int, username: String, profilePhoto: String?, following: Bool) {
        self.username = username
        self.profilePhoto = profilePhoto
        followingStatus = FollowingStatus(fromStatus: following)

        super.init(id: id)
    }

    static func from(response: FollowerResponse) -> FollowerDisplayModel {
        FollowerDisplayModel(id: response.id,
                             username: response.username,
                             profilePhoto: response.profilePhoto,
                             following: response.following)
    }
}

// MARK: - FollowDisplayModel

class FollowDisplayModel: DisplayModel {
    let photoURL: URL?
    let username: String
    let following: Bool

    init(id: Int, photoURL: URL?, username: String, following: Bool) {
        self.photoURL = photoURL
        self.username = username
        self.following = following

        super.init(id: id)
    }

    static func from(response: FollowerResponse) -> FollowDisplayModel {
        FollowDisplayModel(id: response.id,
                           photoURL: URL(string: response.profilePhoto ?? ""),
                           username: response.username,
                           following: response.following)
    }

    static let sample = FollowDisplayModel(id: 1, photoURL: URL(string: "https://images.pexels.com/photos/16141305/pexels-photo-16141305/free-photo-of-view-of-a-white-building.jpeg?auto=compress&cs=tinysrgb&h=240&dpr=2"), username: "sample_user", following: true)
}

// MARK: - GalleryDisplayModel

class GalleryDisplayModel: DisplayModel {
    let photoURL: URL?
    let videoURL: URL?
    let mediaType: MediaTypeResponse

    init(competitionId: Int, photoURL: URL?, videoURL: URL?, mediaType: MediaTypeResponse) {
        self.photoURL = photoURL
        self.videoURL = videoURL
        self.mediaType = mediaType
        super.init(id: competitionId)
    }

    static func from(response: UserSubmissionResponse) -> GalleryDisplayModel {
        let photo = response.media.photo?.medium ?? response.media.video?.thumbnail
        var videoURL: URL?
        if let video = response.media.video?.url { videoURL = URL(string: video) }

        return GalleryDisplayModel(competitionId: response.competitionId,
                                   photoURL: URL(string: photo!),
                                   videoURL: videoURL,
                                   mediaType: response.media.mediaType)
    }
}

// MARK: - LeaderboardUserDisplayModel

class LeaderboardUserDisplayModel: DisplayModel, Identifiable {
    let rankNumber: String
    let rankType: RankType
    let photoURL: String?
    let username: String?
    let score: String

    init(id: Int,
         rankNumber: String,
         rankType: RankType,
         photoURL: String?,
         username: String?,
         score: String) {
        self.rankNumber = rankNumber
        self.rankType = rankType
        self.photoURL = photoURL
        self.username = username
        self.score = score
        super.init(id: id)
    }

    static let sample = LeaderboardUserDisplayModel(id: 1,
                                                    rankNumber: "1",
                                                    rankType: .regular,
                                                    photoURL: "https://res.cloudinary.com/htofkinpe/image/upload/h_128/v1/users/19",
                                                    username: "test",
                                                    score: "10")
}

// MARK: - NotificationDisplayModel

class NotificationDisplayModel: DisplayModel {
    var photoURL: URL?
    var text: AttributedString
    let date: String
    var backgroundColor: Color
    var cornerRadius: CGFloat
    let type: NotificationType
    private var isRead: Bool
    private let response: NotificationResponse?

    init(id: Int, photoURL: String?, text: String?, date: Date, isRead: Bool, type: NotificationType, response: NotificationResponse? = nil) {
        if let url = photoURL {
            self.photoURL = URL(string: url)
        }
        self.text = AttributedString(text ?? "")
        if let markdown = try? AttributedString(markdown: text ?? "") {
            self.text = markdown
        }
        self.date = date.notificationTime // TODO: Implement custom formatter
        backgroundColor = isRead ? Color.clear : Color.blue.opacity(0.16)
        cornerRadius = type == .newFollower ? 24 : 5
        self.type = type
        self.isRead = isRead
        self.response = response
        super.init(id: id)
    }

    func read() -> Bool {
        if !isRead {
            isRead = true
            backgroundColor = isRead ? Color.clear : Color.blue.opacity(0.16)
            return true
        }
        return false
    }

    func getUserId() -> Int? {
        response?.userId
    }

    func getExhbtId() -> Int? {
        response?.exhbtId
    }

    func getEventId() -> Int? {
        response?.eventId
    }

    static let sample = NotificationDisplayModel(id: -1,
                                                 photoURL: "https://res.cloudinary.com/dwkwx0jor/image/upload/c_thumb,g_faces,h_96,w_96/users/48_profile.jpg",
                                                 text: "**Mehmet Tarhan** follows you now",
                                                 date: Date(),
                                                 isRead: true,
                                                 type: .newFollower)

    static func from(response: NotificationResponse) -> NotificationDisplayModel {
        NotificationDisplayModel(id: response.id,
                                 photoURL: response.photoUrl,
                                 text: response.text,
                                 date: response.createdDate,
                                 isRead: response.isRead,
                                 type: response.type,
                                 response: response)
    }
}

// MARK: - MeDetailsDisplayModel

class MeDetailsDisplayModel: DisplayModel {
    let profilePhotoURL: URL?
    let username: String?
    let fullName: String?
    let bio: String?
    let coinsCount: String
    let prizesCount: String
    let votesCount: String
    let followersCount: String
    let followingsCount: String

    init(userId: Int,
         profilePhotoURL: String?,
         username: String?,
         fullName: String?,
         bio: String?,
         coinsCount: Int,
         prizesCount: Int,
         votesCount: Int,
         followersCount: Int,
         followingsCount: Int) {
        self.profilePhotoURL = URL(string: profilePhotoURL ?? "")
        self.username = username
        self.fullName = fullName
        self.bio = bio
        self.coinsCount = "\(coinsCount)"
        self.prizesCount = "\(prizesCount)"
        self.votesCount = "\(votesCount)"
        self.followersCount = "\(followersCount)"
        self.followingsCount = "\(followingsCount)"

        super.init(id: userId)
    }

    static func from(response: UserResponse) -> MeDetailsDisplayModel {
        MeDetailsDisplayModel(userId: response.id,
                              profilePhotoURL: UserSettings.shared.profilePhotoFull,
                              username: "@\(response.username ?? "")",
                              fullName: response.fullName,
                              bio: response.biography,
                              coinsCount: response.coinsCount,
                              prizesCount: response.prizesCount,
                              votesCount: response.votesCount,
                              followersCount: response.followersCount,
                              followingsCount: response.followingCount)
    }

    static let sample = MeDetailsDisplayModel(userId: 48,
                                              profilePhotoURL: "https://res.cloudinary.com/dwkwx0jor/image/upload/c_thumb,g_faces/users/48_profile.jpg",
                                              username: "memtarhan",
                                              fullName: "Mehmet Tarhan",
                                              bio: "Rock 'n Roll baby! Heyyyy heyyyy , how’s it going?Let’s go for multi line bio. Rock 'n Roll baby! Heyyyy heyyyy , how’s it going?Let’s go for multi line bio. Rock 'n Roll baby! Heyyyy heyyyy , how’s it going?Let’s go for multi line bio.",
                                              coinsCount: 120,
                                              prizesCount: 5,
                                              votesCount: 100,
                                              followersCount: 20,
                                              followingsCount: 10)
}

class ProfileDetailsDisplayModel: DisplayModel {
    var profilePhotoURL: String?
    var profileThumbnailURL: String?
    var username: String
    var fullName: String?
    var bio: String?
    var followingStatus: FollowingStatus
    var coinsCount: String
    var prizesCount: String
    var votesCount: String
    var followersCount: String
    var followingCount: String
    var isMe: Bool
    let tags: [TagDisplayModel]

    init(userId: Int,
         profilePhotoURL: String?,
         profileThumbnailURL: String?,
         username: String,
         fullName: String?,
         bio: String?,
         following: Bool,
         coinsCount: Int,
         prizesCount: Int,
         votesCount: Int,
         followersCount: Int,
         followingCount: Int,
         isMe: Bool,
         tags: [TagDisplayModel]) {
        self.profilePhotoURL = profilePhotoURL
        self.profileThumbnailURL = profileThumbnailURL
        self.username = username
        self.fullName = fullName
        self.bio = bio
        followingStatus = FollowingStatus(fromStatus: following)
        self.coinsCount = "\(coinsCount)"
        self.prizesCount = "\(prizesCount)"
        self.votesCount = "\(votesCount)"
        self.followersCount = "\(followersCount)"
        self.followingCount = "\(followingCount)"
        self.isMe = isMe
        self.tags = tags
        super.init(id: userId)
    }

    func update(withResponse response: UserResponse) {
        profilePhotoURL = UserSettings.shared.profilePhotoFull
        profileThumbnailURL = UserSettings.shared.profilePhotoFull
        username = "@\(response.username ?? "")"
        fullName = response.fullName
        bio = response.biography
        followingStatus = FollowingStatus(fromStatus: response.following)
        coinsCount = "\(response.coinsCount)"
        prizesCount = "\(response.prizesCount)"
        votesCount = "\(response.votesCount)"
        followersCount = "\(response.followersCount)"
        followingCount = "\(response.followingCount)"
        isMe = UserSettings.shared.id == response.id
    }

    static func from(response: UserResponse, tags: [UserTagResponse]) -> ProfileDetailsDisplayModel {
        ProfileDetailsDisplayModel(userId: response.id,
                                   profilePhotoURL: response.media?.photo?.full,
                                   profileThumbnailURL: response.media?.photo?.thumbnail,
                                   username: "@\(response.username ?? "")",
                                   fullName: response.fullName,
                                   bio: response.biography,
                                   following: response.following,
                                   coinsCount: response.coinsCount,
                                   prizesCount: response.prizesCount,
                                   votesCount: response.votesCount,
                                   followersCount: response.followersCount,
                                   followingCount: response.followingCount,
                                   isMe: UserSettings.shared.id == response.id,
                                   tags: tags.map { TagDisplayModel(id: $0.id, title: $0.label) })
    }
}

class ContactDisplayModel: DisplayModel {
    var fullName: String?
    var image: UIImage?
    var imageURL: String?
    var phoneNumber: String?

    init(id: Int,
         fullName: String? = nil,
         image: UIImage? = nil,
         imageURL: String? = nil,
         phoneNumber: String? = nil) {
        self.fullName = fullName
        self.image = image
        self.imageURL = imageURL
        self.phoneNumber = phoneNumber

        super.init(id: id)
    }
}

class FollowingContactDisplayModel: DisplayModel {
    let userId: Int
    var fullName: String?
    var image: UIImage?
    var imageURL: String?

    init(id: Int,
         userId: Int,
         fullName: String? = nil,
         image: UIImage? = nil,
         imageURL: String? = nil) {
        self.userId = userId
        self.fullName = fullName
        self.image = image
        self.imageURL = imageURL

        super.init(id: id)
    }
}

class ExhbtContentDisplayModel: DisplayModel {
    let url: String?
    let videoURL: String?

    init(id: Int, url: String?, videoURL: String?) {
        self.url = url
        self.videoURL = videoURL
        super.init(id: id)
    }
}

class PostDisplayModel: DisplayModel {
    var image: UIImage?
    let imageURL: String?
    let videoURL: URL?
    let aspectRatio: Double
    var likesCount: Int
    var dislikesCount: Int
    let isOwn: Bool
    let eventId: Int
    var interaction: PostInteractionType?

    init(id: Int,
         image: UIImage? = nil,
         imageURL: String?,
         videoURL: URL?,
         aspectRatio: Double,
         likesCount: Int,
         dislikesCount: Int,
         isOwn: Bool,
         eventId: Int,
         interaction: PostInteractionType?) {
        self.image = image
        self.imageURL = imageURL
        self.videoURL = videoURL
        self.aspectRatio = aspectRatio
        self.likesCount = likesCount
        self.dislikesCount = dislikesCount
        self.isOwn = isOwn
        self.eventId = eventId
        self.interaction = interaction

        super.init(id: id)
    }

    init(withResponse response: PostResponse) {
        if let video = response.media?.video {
            videoURL = URL(string: video.url)
            imageURL = nil

        } else if let photo = response.media?.photo {
            imageURL = photo.medium
            videoURL = nil

        } else {
            imageURL = nil
            videoURL = nil
        }
        aspectRatio = response.media?.aspectRatio ?? 1
        likesCount = response.likesCount
        dislikesCount = response.dislikesCount
        isOwn = response.isOwn
        eventId = response.eventId
        if let interaction = response.interaction {
            self.interaction = PostInteractionType(withResponse: interaction)

        } else {
            interaction = nil
        }

        super.init(id: response.id)
    }

    static let sample = PostDisplayModel(id: 1, imageURL: "https://res.cloudinary.com/htofkinpe/image/upload/c_fill,g_auto,h_512,w_512/v1/posts/15", videoURL: nil, aspectRatio: 1.3, likesCount: 10, dislikesCount: 5, isOwn: true, eventId: 1, interaction: .like)
}

// MARK: - PrizeDisplayModel

class PrizeDisplayModel: DisplayModel {
    let exhbtId: Int
    let winnerId: Int
    let points: Int
    let medalType: MedalType

    init(id: Int, exhbtId: Int, winnerId: Int, points: Int, medalType: MedalType) {
        self.exhbtId = exhbtId
        self.winnerId = winnerId
        self.points = points
        self.medalType = medalType

        super.init(id: id)
    }

    static func from(response: PrizeResponse) -> PrizeDisplayModel {
        PrizeDisplayModel(id: response.id,
                          exhbtId: response.exhbtId,
                          winnerId: response.winnerId,
                          points: response.points,
                          medalType: response.type)
    }

    static let sample = PrizeDisplayModel(id: 1, exhbtId: 1, winnerId: 1, points: 10, medalType: .gold)
}
