//
//  AppAssembler.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 02/09/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import Swinject
import UIKit

class AppAssembler {
    static let shared = AppAssembler()

    private(set) var assembler: Assembler?

    // TODO: Sort it by name
    /// - Initializing dependency injection
    func initDI() {
        assembler = Assembler([
            /// - Popups
            CompetitionsInfoPopupAssembly(),
            NewExhbtPopupAssembly(),

            /// - Screens
            ChooseCompetitorsAssembly(),
            ExhbtAssembly(),
            ExhbtDetailsAssembly(),
            ExhbtResultAssembly(),
            ExploreAssembly(),
            ExhbtsAssembly(),
            ExhbtsSearchAssembly(),
            EventResultAssembly(),
            FeedsAssembly(),
            FollowerListAssembly(),
            FollowsAssembly(),
            GalleryAssembly(),
            HomeAssembly(),
            LeaderboardAssembly(),
            LocationsAssembly(),
            MeAssembly(),
            MissingAccountDetailsAssembly(),
            NewCompetitionAssembly(),
            NewCompetitionStatusAssembly(),
            NewExhbtAssembly(),
            NewExhbtSetupAssembly(),
            NewPostAssembly(),
            NotificationsAssembly(),
            SigninAssembly(),
            SplashAssembly(),
            TabBarAssembly(),
            VoteStyleViewerAssembly(),
            SettingsAssembly(),
            ProfileAccountAssembly(),
            NotificationSettingsAssembly(),
            DownloadDataAssembly(),
            ReportBugAssembly(),
            UpdateProfileAssembly(),
            UserAssembly(),
            VotesAssembly(),
            VotingAssembly(),
            OnboardingAssembly(),
            ExhbtContentAssembly(),
            NewEventAssembly(),
            EventAssembly(),
            EventsAssembly(),
            InviteAssembly(),
            PostsAssembly(),
            PrizesAssembly(),

            /// - Services
            APIServiceAssembly(),
            RealtimeSyncAssembly(),
        ])
        assembler?.apply(assembly: CoordinatorFactoryAssembly(assembler: assembler!))
    }
}
