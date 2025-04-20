//
//  CoordinatorFactory.swift
//  Exhbt
//
//  Created Mehmet Tarhan on 04/03/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import Foundation
import Swinject

// MARK: Sort it by name

protocol ViewControllerFactoryProtocol: AnyObject {
    var chooseCompetitors: ChooseCompetitorsViewController { get }
    var competitionsInfoPopup: CompetitionsInfoPopup { get }
    var downloadData: DownloadDataViewController { get }
    var exhbt: ExhbtViewController { get }
    var exhbtDetails: ExhbtDetailsViewController { get }
    var exhbtResult: ExhbtResultViewController { get }
    var exhbts: ExhbtsViewController { get }
    var explore: ExploreViewController { get }
    var feeds: FeedsViewController { get }
    var follows: FollowsViewController { get }
    var followerList: FollowerListViewController { get }
    var galleryVertical: GalleryVerticalViewController { get }
    var home: HomeViewController { get }
    var leaderboard: LeaderboardViewController { get }
    var locations: LocationsViewController { get }
    var me: MeViewController { get }
    var missingAccountDetails: MissingAccountDetailsViewController { get }
    var newCompetition: NewCompetitionViewController { get }
    var newCompetitionStatus: NewCompetitionStatusViewController { get }
    var newExhbt: NewExhbtViewController { get }
    var newExhbtSetup: NewExhbtSetupViewController { get }
    var newExhbtPopup: NewExhbtPopup { get }
    var newPost: NewPostViewController { get }
    var notifications: NotificationsViewController { get }
    var notificationSettings: NotificationSettingsViewController { get }
    var profileAccount: ProfileAccountViewController { get }
    var reportBug: ReportBugViewController { get }
    var settings: SettingsViewController { get }
    var tabBar: TabBarViewController { get }
    var updateProfile: UpdateProfileViewController { get }
    var user: UserViewController { get }
    var voteStyleViewer: VoteStyleViewer { get }
    var votes: VotesViewController { get }
    var voting: VotingViewController { get }
    var exploreSearch: ExploreSearchViewController { get }
    var onboarding: OnboardingViewController { get }
    var exhbtContent: ExhbtContentViewController { get }
    var newEvent: NewEventViewController { get }
    var event: EventViewController { get }
    var events: EventsViewController { get }
    var eventResult: EventResultViewController { get }
    var invite: InviteViewController { get }
    var posts: PostsViewController { get }
    var prizes: PrizesViewController { get }
}

class ViewControllerFactory: ViewControllerFactoryProtocol {
    private let assembler: Assembler

    init(assembler: Assembler) {
        self.assembler = assembler
    }

    var onboarding: OnboardingViewController { assembler.resolver.resolve(OnboardingViewController.self)! }
    var chooseCompetitors: ChooseCompetitorsViewController { assembler.resolver.resolve(ChooseCompetitorsViewController.self)! }
    var competitionsInfoPopup: CompetitionsInfoPopup { assembler.resolver.resolve(CompetitionsInfoPopup.self)! }
    var downloadData: DownloadDataViewController { assembler.resolver.resolve(DownloadDataViewController.self)! }
    var exhbt: ExhbtViewController { assembler.resolver.resolve(ExhbtViewController.self)! }
    var explore: ExploreViewController { assembler.resolver.resolve(ExploreViewController.self)! }
    var exhbtDetails: ExhbtDetailsViewController { assembler.resolver.resolve(ExhbtDetailsViewController.self)! }
    var exhbtResult: ExhbtResultViewController { assembler.resolver.resolve(ExhbtResultViewController.self)! }
    var exhbts: ExhbtsViewController { assembler.resolver.resolve(ExhbtsViewController.self)! }
    var feeds: FeedsViewController { assembler.resolver.resolve(FeedsViewController.self)! }
    var follows: FollowsViewController { assembler.resolver.resolve(FollowsViewController.self)! }
    var followerList: FollowerListViewController { assembler.resolver.resolve(FollowerListViewController.self)! }
    var galleryVertical: GalleryVerticalViewController { assembler.resolver.resolve(GalleryVerticalViewController.self)! }
    var home: HomeViewController { assembler.resolver.resolve(HomeViewController.self)! }
    var leaderboard: LeaderboardViewController { assembler.resolver.resolve(LeaderboardViewController.self)! }
    var locations: LocationsViewController { assembler.resolver.resolve(LocationsViewController.self)! }
    var me: MeViewController { assembler.resolver.resolve(MeViewController.self)! }
    var missingAccountDetails: MissingAccountDetailsViewController { assembler.resolver.resolve(MissingAccountDetailsViewController.self)! }
    var newCompetition: NewCompetitionViewController { assembler.resolver.resolve(NewCompetitionViewController.self)! }
    var newCompetitionStatus: NewCompetitionStatusViewController { assembler.resolver.resolve(NewCompetitionStatusViewController.self)! }
    var newExhbt: NewExhbtViewController { assembler.resolver.resolve(NewExhbtViewController.self)! }
    var newExhbtSetup: NewExhbtSetupViewController { assembler.resolver.resolve(NewExhbtSetupViewController.self)! }
    var newExhbtPopup: NewExhbtPopup { assembler.resolver.resolve(NewExhbtPopup.self)! }
    var newPost: NewPostViewController { assembler.resolver.resolve(NewPostViewController.self)! }
    var notifications: NotificationsViewController { assembler.resolver.resolve(NotificationsViewController.self)! }
    var notificationSettings: NotificationSettingsViewController { assembler.resolver.resolve(NotificationSettingsViewController.self)! }
    var profileAccount: ProfileAccountViewController { assembler.resolver.resolve(ProfileAccountViewController.self)! }
    var reportBug: ReportBugViewController { assembler.resolver.resolve(ReportBugViewController.self)! }
    var settings: SettingsViewController { assembler.resolver.resolve(SettingsViewController.self)! }
    var tabBar: TabBarViewController { assembler.resolver.resolve(TabBarViewController.self)! }
    var updateProfile: UpdateProfileViewController { assembler.resolver.resolve(UpdateProfileViewController.self)! }
    var user: UserViewController { assembler.resolver.resolve(UserViewController.self)! }
    var voteStyleViewer: VoteStyleViewer { assembler.resolver.resolve(VoteStyleViewer.self)! }
    var votes: VotesViewController { assembler.resolver.resolve(VotesViewController.self)! }
    var voting: VotingViewController { assembler.resolver.resolve(VotingViewController.self)! }
    var exploreSearch: ExploreSearchViewController { assembler.resolver.resolve(ExploreSearchViewController.self)! }
    var exhbtContent: ExhbtContentViewController {
        assembler.resolver.resolve(ExhbtContentViewController.self)!
    }

    var newEvent: NewEventViewController {
        assembler.resolver.resolve(NewEventViewController.self)!
    }

    var event: EventViewController { assembler.resolver.resolve(EventViewController.self)! }
    
    var events: EventsViewController {
        assembler.resolver.resolve(EventsViewController.self)!
    }

    var eventResult: EventResultViewController {
        assembler.resolver.resolve(EventResultViewController.self)!
    }

    var invite: InviteViewController { assembler.resolver.resolve(InviteViewController.self)! }

    var posts: PostsViewController { assembler.resolver.resolve(PostsViewController.self)! }
    var prizes: PrizesViewController { assembler.resolver.resolve(PrizesViewController.self)! }
}
