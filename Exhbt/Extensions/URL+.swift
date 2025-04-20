//
//  URL+.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 25/12/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import Foundation

extension URL {
    struct Auth {
        static func register() -> URL? {
            URL(string: "\(BaseURL.shared)/auth/register/")
        }

        static func signIn() -> URL? {
            URL(string: "\(BaseURL.shared)/auth/signin/")
        }

        static func appleSignIn() -> URL? {
            URL(string: "\(BaseURL.shared)/auth/signin")
        }
    }

    struct Competition {
        static func get(competitionId: Int) -> URL? {
            URL(string: "\(BaseURL.shared)/competition?competition_id=\(competitionId)")
        }

        static func create(exhbtId: Int) -> URL? {
            URL(string: "\(BaseURL.shared)/competition?exhbt_id=\(exhbtId)")
        }

        static func photo(competitionId: Int) -> URL? {
            URL(string: "\(BaseURL.shared)/competition/photo?competition_id=\(competitionId)")
        }

        static func video(competitionId: Int) -> URL? {
            URL(string: "\(BaseURL.shared)/competition/video?competition_id=\(competitionId)")
        }

        static func vote(competitionId: Int) -> URL? {
            URL(string: "\(BaseURL.shared)/competition/vote?competition_id=\(competitionId)")
        }

        static func removeVote(competitionId: Int) -> URL? {
            URL(string: "\(BaseURL.shared)/competition/vote?competition_id=\(competitionId)")
        }
    }

    struct Event {
        static func getResult(withId id: Int) -> URL? {
            URL(string: "\(BaseURL.shared)/events/\(id)/result")
        }

        static func getSingle(withId id: Int) -> URL? {
            URL(string: "\(BaseURL.shared)/events/\(id)")
        }

        static func get(keyword: String?,
                        showNSFWContent: Bool,
                        showAllEvents: Bool,
                        sortByLocation: Bool,
                        longitude: Double? = nil,
                        latitude: Double? = nil,
                        page: Int = 1,
                        limit: Int = 15) -> URL? {
            var coreURL = "\(BaseURL.shared)/events?show_all_events=\(showAllEvents)&show_nsfw_content=\(showNSFWContent)&sort_by_location=\(sortByLocation)&page=\(page)&limit=\(limit)"
            if let keyword {
                coreURL.append("&keyword=\(keyword)")
            }

            if let longitude, let latitude {
                coreURL.append("&longitude=\(longitude)&latitude=\(latitude)")
            }
            return URL(string: coreURL)
        }

        static func get(exhbtId: Int) -> URL? {
            URL(string: "\(BaseURL.shared)/events/")
        }

        static func details(exhbtId: Int) -> URL? {
            URL(string: "\(BaseURL.shared)/exhbt/\(exhbtId)/details")
        }

        static func create() -> URL? {
            URL(string: "\(BaseURL.shared)/events")
        }

        static func delete(eventId: Int) -> URL? {
            URL(string: "\(BaseURL.shared)/events/\(eventId)")
        }

        static func join(eventId: Int) -> URL? {
            URL(string: "\(BaseURL.shared)/events/\(eventId)/join")
        }

        static func post(eventId: Int) -> URL? {
            URL(string: "\(BaseURL.shared)/posts?event_id=\(eventId)")
        }

        static func posts(eventId: Int, page: Int, limit: Int = 10) -> URL? {
            URL(string: "\(BaseURL.shared)/events/\(eventId)/posts?page=\(page)&limit=\(limit)")
        }

        static func coverPhoto(eventId: Int) -> URL? {
            URL(string: "\(BaseURL.shared)/events/\(eventId)/upload_cover_photo")
        }

        static func search() -> URL? {
            URL(string: "\(BaseURL.shared)/events/search")
        }

        static func shareInvitation(eventId: Int) -> URL? {
            URL(string: "\(BaseURL.shared)/events/\(eventId)/share_invitation")
        }

        static func invite(eventId: Int) -> URL? {
            URL(string: "\(BaseURL.shared)/events/\(eventId)/invite")
        }
    }

    struct Exhbt {
        static func get(exhbtId: Int) -> URL? {
            URL(string: "\(BaseURL.shared)/exhbt/\(exhbtId)")
        }

        static func details(exhbtId: Int) -> URL? {
            URL(string: "\(BaseURL.shared)/exhbt/\(exhbtId)/details")
        }

        static func result(exhbtId: Int) -> URL? {
            URL(string: "\(BaseURL.shared)/exhbt/\(exhbtId)/result")
        }

        static func create() -> URL? {
            URL(string: "\(BaseURL.shared)/exhbt/")
        }

        static func delete(exhbtId: Int) -> URL? {
            URL(string: "\(BaseURL.shared)/exhbt/\(exhbtId)")
        }

        static func joinWithInvitation(exhbtId: Int, invitationId: Int) -> URL? {
            URL(string: "\(BaseURL.shared)/exhbt/\(exhbtId)/join?invitation_id=\(invitationId)")
        }

        static func join(exhbtId: Int) -> URL? {
            URL(string: "\(BaseURL.shared)/exhbt/\(exhbtId)/join")
        }

        static func addCompetitors(exhbtId: Int) -> URL? {
            URL(string: "\(BaseURL.shared)/exhbt/\(exhbtId)/add_competitors")
        }

        static func shareInvitation(exhbtId: Int) -> URL? {
            URL(string: "\(BaseURL.shared)/exhbt/\(exhbtId)/share_invitation")
        }

        static func flag(exhbtId: Int) -> URL? {
            URL(string: "\(BaseURL.shared)/exhbt/\(exhbtId)/flag")
        }
    }

    struct Feeds {
        static func get(atPage page: Int = 1, limit: Int = 5) -> URL? {
            URL(string: "\(BaseURL.shared)/feeds?page=\(page)&limit=\(limit)")
        }
    }

    struct Flash {
        static func get(atPage page: Int = 1) -> URL? {
            URL(string: "\(BaseURL.shared)/flash?page=\(page)")
        }

        static func like(competitionId: Int) -> URL? {
            URL(string: "\(BaseURL.shared)/flash/like?competition_id=\(competitionId)")
        }

        static func dislike(competitionId: Int) -> URL? {
            URL(string: "\(BaseURL.shared)/flash/dislike?competition_id=\(competitionId)")
        }
    }

    struct Exhbts {
        static func get(forTag tag: String? = nil, keyword: String? = nil, page: Int = 1, limit: Int = 30) -> URL? {
            var coreURL = "\(BaseURL.shared)/exhbts?page=\(page)&limit=\(limit)"
            if let tag {
                coreURL.append("&tag=\(tag)")
            }
            if let keyword {
                coreURL.append("&keyword=\(keyword)")
            }

            return URL(string: coreURL)
        }

        static func getSingle(withId id: Int) -> URL? {
            URL(string: "\(BaseURL.shared)/exhbts/\(id)")
        }

        static func getExploreUser(withKeyword keyword: String, page: Int = 1, limit: Int = 5) -> URL? {
            return URL(string: "\(BaseURL.shared)/explore/users?keyword=\(keyword)&page=\(page)&limit=\(limit)")
        }
    }

    struct Invitation {
        static func get(withId id: Int) -> URL? {
            URL(string: "\(BaseURL.shared)/invitations/\(id)")
        }

        static func accept(withId id: Int) -> URL? {
            URL(string: "\(BaseURL.shared)/invitations/\(id)")
        }
    }

    struct Leaderboard {
        static func get(forTag tag: String? = nil, keyword: String? = nil, page: Int = 1, limit: Int = 30) -> URL? {
            var coreURL = "\(BaseURL.shared)/leaderboard?page=\(page)&limit=\(limit)"
            if let keyword {
                coreURL.append("&keyword=\(keyword)")
            }

            if let tag {
                coreURL.append("&tag=\(tag)")
            }
            return URL(string: coreURL)
        }

        static func searchUser(searchText: String, page: Int = 1, limit: Int = 3) -> URL? {
            URL(string: "\(BaseURL.shared)/leaderboard/search?keyword=\(searchText)&page=\(page)&limit=\(limit)")
        }
    }

    struct Me {
        static func get() -> URL? {
            URL(string: "\(BaseURL.shared)/me")
        }

        static func delete() -> URL? {
            URL(string: "\(BaseURL.shared)/me")
        }

        static func update() -> URL? {
            URL(string: "\(BaseURL.shared)/me")
        }

        static func elibility() -> URL? {
            URL(string: "\(BaseURL.shared)/me/eligibility")
        }

        static func username() -> URL? {
            URL(string: "\(BaseURL.shared)/me/username")
        }

        static func profilePhoto() -> URL? {
            URL(string: "\(BaseURL.shared)/me/profile_photo")
        }

        static func coverPhoto() -> URL? {
            URL(string: "\(BaseURL.shared)/me/cover_photo")
        }

        static func createdExhbts(atPage page: Int = 1, limit: Int = 3) -> URL? {
            URL(string: "\(BaseURL.shared)/me/created_exhbts?page=\(page)&limit=\(limit)")
        }

        static func participatedExhbts(atPage page: Int = 1, limit: Int = 3) -> URL? {
            URL(string: "\(BaseURL.shared)/me/participated_exhbts?page=\(page)&limit=\(limit)")
        }

        static func notifications(atPage page: Int = 1, limit: Int = 5) -> URL? {
            URL(string: "\(BaseURL.shared)/me/notifications?page=\(page)&limit=\(limit)")
        }

        static func notificationsDeviceToken() -> URL? {
            URL(string: "\(BaseURL.shared)/me/notifications/device_token")
        }

        static func notificationsBadgeCount() -> URL? {
            URL(string: "\(BaseURL.shared)/me/notifications/badge_count")
        }

        static func readNotification(withId id: Int) -> URL? {
            URL(string: "\(BaseURL.shared)/me/notifications/?notification_id=\(id)")
        }

        static func followers(atPage page: Int = 1, limit: Int = 10) -> URL? {
            URL(string: "\(BaseURL.shared)/me/followers/?page=\(page)&limit=\(limit)")
        }

        static func followings(atPage page: Int = 1, limit: Int = 10) -> URL? {
            URL(string: "\(BaseURL.shared)/me/followings/?page=\(page)&limit=\(limit)")
        }

        static func submissions(atPage page: Int = 1, limit: Int = 10) -> URL? {
            URL(string: "\(BaseURL.shared)/me/submissions/?page=\(page)&limit=\(limit)")
        }

        static func publicExhbts(atPage page: Int = 1, limit: Int = 10) -> URL? {
            URL(string: "\(BaseURL.shared)/me/exhbts?exhbt_type=public&page=\(page)&limit=\(limit)")
        }

        static func privateExhbts(atPage page: Int = 1, limit: Int = 10) -> URL? {
            URL(string: "\(BaseURL.shared)/me/private_exhbts?exhbt_type=private&page=\(page)&limit=\(limit)")
        }

        static func votedExhbts() -> URL? {
            URL(string: "\(BaseURL.shared)/me/voted_exhbts")
        }

        static func followersSearch(withKeyword keyword: String, page: Int = 1, limit: Int = 10) -> URL? {
            URL(string: "\(BaseURL.shared)/me/followers/search/?keyword=\(keyword)&page=\(page)&limit=\(limit)")
        }

        static func followingsSearch(withKeyword keyword: String, page: Int = 1, limit: Int = 10) -> URL? {
            URL(string: "\(BaseURL.shared)/me/followings/search/?keyword=\(keyword)&page=\(page)&limit=\(limit)")
        }

        static func follow(withId id: Int) -> URL? {
            URL(string: "\(BaseURL.shared)/me/follow/?user_id=\(id)")
        }

        static func unfollow(withId id: Int) -> URL? {
            URL(string: "\(BaseURL.shared)/me/follow/?user_id=\(id)")
        }

        static func events(atPage page: Int = 1, limit: Int = 3) -> URL? {
            URL(string: "\(BaseURL.shared)/me/events?page=\(page)&limit=\(limit)")
        }

        static func tags() -> URL? {
            URL(string: "\(BaseURL.shared)/me/tags")
        }

        static func prizes() -> URL? {
            URL(string: "\(BaseURL.shared)/me/prizes")
        }
    }

    struct User {
        static func get(withId id: Int) -> URL? {
            URL(string: "\(BaseURL.shared)/users/\(id)")
        }

        static func submissions(withId id: Int, atPage page: Int = 1, limit: Int = 10) -> URL? {
            URL(string: "\(BaseURL.shared)/users/\(id)/submissions/?page=\(page)&limit=\(limit)")
        }

        static func publicExhbts(withId id: Int, atPage page: Int = 1, limit: Int = 3) -> URL? {
            URL(string: "\(BaseURL.shared)/users/\(id)/public_exhbts?page=\(page)&limit=\(limit)")
        }

        static func votedExhbts(withId id: Int) -> URL? {
            URL(string: "\(BaseURL.shared)/users/\(id)/voted_exhbts")
        }

        static func events(withId id: Int, atPage page: Int = 1, limit: Int = 3) -> URL? {
            URL(string: "\(BaseURL.shared)/users/\(id)/events?page=\(page)&limit=\(limit)")
        }

        static func createdExhbts(withId id: Int, atPage page: Int = 1, limit: Int = 3) -> URL? {
            URL(string: "\(BaseURL.shared)/users/\(id)/created_exhbts?page=\(page)&limit=\(limit)")
        }

        static func participatedExhbts(withId id: Int, atPage page: Int = 1, limit: Int = 3) -> URL? {
            URL(string: "\(BaseURL.shared)/users/\(id)/participated_exhbts?page=\(page)&limit=\(limit)")
        }

        static func followers(withId id: Int, page: Int = 1, limit: Int = 10) -> URL? {
            URL(string: "\(BaseURL.shared)/users/\(id)/followers/?page=\(page)&limit=\(limit)")
        }

        static func followings(withId id: Int, page: Int = 1, limit: Int = 10) -> URL? {
            URL(string: "\(BaseURL.shared)/users/\(id)/followings/?page=\(page)&limit=\(limit)")
        }

        static func followersSearch(withId id: Int, keyword: String, page: Int = 1, limit: Int = 10) -> URL? {
            URL(string: "\(BaseURL.shared)/users/\(id)/followers/search/?keyword=\(keyword)&page=\(page)&limit=\(limit)")
        }

        static func followingsSearch(withId id: Int, keyword: String, page: Int = 1, limit: Int = 10) -> URL? {
            URL(string: "\(BaseURL.shared)/users/\(id)/followings/search/?keyword=\(keyword)&page=\(page)&limit=\(limit)")
        }

        static func tags(withId id: Int) -> URL? {
            URL(string: "\(BaseURL.shared)/users/\(id)/tags")
        }

        static func prizes(withId id: Int) -> URL? {
            URL(string: "\(BaseURL.shared)/users/\(id)/prizes")
        }
    }

    struct Tag {
        static func popular() -> URL? {
            return URL(string: "\(BaseURL.shared)/tags/popular")
        }
    }

    struct Post {
        static func post(eventId: Int) -> URL? {
            return URL(string: "\(BaseURL.shared)/posts/\(eventId)/upload_content")
        }

        static func photo(postId: Int) -> URL? {
            return URL(string: "\(BaseURL.shared)/posts/\(postId)/photo")
        }

        static func video(postId: Int) -> URL? {
            return URL(string: "\(BaseURL.shared)/posts/\(postId)/video")
        }

        static func like(postId: Int) -> URL? {
            return URL(string: "\(BaseURL.shared)/posts/\(postId)/like")
        }

        static func dislike(postId: Int) -> URL? {
            return URL(string: "\(BaseURL.shared)/posts/\(postId)/dislike")
        }

        static func delete(postId: Int) -> URL? {
            return URL(string: "\(BaseURL.shared)/posts/\(postId)")
        }
    }
}
