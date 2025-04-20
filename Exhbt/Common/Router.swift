//
//  Router.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 02/09/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import Foundation
import SafariServices
import UIKit

// MARK: Sort it by name

// TODO: Follow the pattern for refactor
/// Provides navigations on view controller that inherits
protocol Router {
    /// Displays `New Competitions` with given Exhbt id as full screen
    /// - Parameters:
    ///   - id: Id of Exhbt that is presented
    ///   - type: Type of presentation mode, i.e  `new`, `join`, `joinWithInvitation`
    func presentNewCompetition(withExhbt id: Int, type: NewCompetitionType, delegate: NewCompetitionDelegate?)

    /**
     Displays  Exhbt
     - Parameter withId: The exhbt id that will be presented
     */
    func presentExhbt(withId id: Int, displayMode: ExhbtDetailsDisplayMode, competitionMode: NewCompetitionType)

    /// Pushes `ExhbtResult` with given Exhbt Id into navigation stack
    /// - Parameter id: Exhbt that will be presented
    func presentExhbtResult(withId id: Int)

    /// Pushes `FollowerList` with given user profile into navigation stack
    /// - Parameter user: User profile that will be presented
    /// - Parameter shouldShowFollowers: Which list should be displayed
    func presentFollowers(withUser user: ProfileDetailsDisplayModel?, shouldShowFollowers: Bool)

    /// Pushes `Follows` with given user profile into navigation stack
    /// - Parameter userId: User id whose profile will be presented
    func presentFollows(forUser userId: Int?)

    /// Displays New Exhbt
    func presentNewExhbt(delegate: NewExhbtDelegate?)

    /// Displays New Exhbt setup
    /// - Parameter asset: Asset
    /// - Parameter exhbtType: ExhbtType
    /// - Parameter delegate: NewExhbtDelegate
    func presentNewExhbtSetup(withAsset asset: CCAsset, exhbtType: ExhbtType, delegate: NewExhbtDelegate?)

    /**
     Displays Vote styles
     - Parameter on: The source view controller -delegate

     */
    func presentVoteStyles(on delegate: VoteStyleViewerDelegate)

    /**
     Displays Notifications
     */
    func presentNotifications()

    /**
     Displays New Competition Status
     - Parameter type: Type of status
     - Parameter source: Source

     Types
     * pub -> public
     * priv -> private
     * contacts
     */
    func presentNewCompetitionStatus(withType type: NewCompetitionStatusType, fromSource source: UIViewController)

    /**
     Displays Choose Competitors
     - Parameter exhbtId: Exhbt Id
     - Parameter delegate: Delegate

     */
    func presentChooseCompetitors(exhbtId: Int, delegate: ChooseCompetitorsDelegate?)

    /**
     Displays Competitions Info Popup (Half screen)
     */
    func presentCompetitionsInfoPopup()

    func presentNewExhbtPopup(exhbtId: Int, exhbtType: ExhbtType, delegate: NewExhbtDelegate?)

    func presentMissingAccountDetails()

    func presentSettings()

    func presentProfileAccount()

    func presentNotificationSettings()

    func presentDownloadData()

    func presentReportBug()

    func displayAlert(withTitle title: String?, message: String?, completion: (() -> Void)?)

    func displayWarningAlert(withTitle title: String?, message: String?, completion: @escaping (() -> Void))

    func presentUpdateProfile(profileFieldType: UpdateProfileFieldType)

    func presentSafareViewController(url: String)

    func presentGalleryVertical(_ items: [GalleryDisplayModel], selected: Int)

    func presentUser(withId id: Int)

    /// Present `SignIn` as full screen
    func presentSignIn()

    /// Present `TabBar` as full screen
    func presentTabBar()

    /// Pushes `Votes` with given user id into navigation stack. if userId is not given, it will display current user's votes
    /// - Parameters:
    ///   - userId: Id of User that is presented, default value is nil
    func presentVotes(withUser userId: Int?)

    /// Pushes `Voting` with given Exhbt id into navigation stack
    /// - Parameters:
    ///   - exhbt: Id of Exhbt that is presented
    func presentVoting(withExhbt exhbt: FeedPreviewDisplayModel, delegate: VotingDelegate?)

    func presentExploreSearch(searchQuery: String, category: Category)

    func presentOnboarding()

    func presentEvent(eventId: Int)
    func presentEventResult(eventId: Int)

    func presentLocations(delegate: LocationsDelegate?)

    func presentNewPost(event: EventDisplayModel?)

    func presentPosts(forEvent event: Int)

    /// Pushes `Prizes` with given user id into navigation stack.
    /// - Parameter userId: User id of displayed user with prizes
    func presentPrizes(forUser userId: Int)
}

extension Router where Self: UIViewController {
    private var factory: ViewControllerFactoryProtocol? {
        (AppAssembler.shared.assembler?.resolver.resolve(ViewControllerFactoryProtocol.self))!
    }

    // MARK: - OnBoarding

    func presentOnboarding() {
        guard let newCompetition = factory?.onboarding else { return }
        let navController = UINavigationController(rootViewController: newCompetition)
        navController.modalPresentationStyle = .fullScreen
        navController.modalTransitionStyle = .crossDissolve
        present(navController, animated: true)
    }

    // MARK: - New Competitions

    func presentNewCompetition(withExhbt id: Int, type: NewCompetitionType, delegate: NewCompetitionDelegate?) {
        debugLog(self, #function)

        guard let newCompetition = factory?.newCompetition else { return }
        newCompetition.exhbtId = id
        newCompetition.type = type
        newCompetition.delegate = delegate
        let navigationController = UINavigationController(rootViewController: newCompetition)
        present(navigationController, animated: true)
    }

    // MARK: - Exhbt

    func presentExhbt(withId id: Int, displayMode: ExhbtDetailsDisplayMode = .viewing, competitionMode: NewCompetitionType = .join) {
        debugLog(self, #function)

        guard let exhbt = factory?.exhbtDetails else { return }
        exhbt.exhbtId = id
        exhbt.displayMode = displayMode
        exhbt.competitionMode = competitionMode

        exhbt.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        exhbt.hidesBottomBarWhenPushed = true
        if let navigationController {
            navigationController.pushViewController(exhbt, animated: true)

        } else {
            let navigationController = UINavigationController(rootViewController: exhbt)
            present(navigationController, animated: true)
        }
    }

    // MARK: - Exhbt Result

    func presentExhbtResult(withId id: Int) {
        debugLog(self, #function)

        guard let destination = factory?.exhbtResult else { return }
        destination.exhbtId = id

        destination.hidesBottomBarWhenPushed = true

        navigationController?.pushViewController(destination, animated: true)

//        let navigationController = UINavigationController(rootViewController: destination)
//        navigationController.modalPresentationStyle = .pageSheet
//
//        if let sheet = navigationController.sheetPresentationController {
//            sheet.detents = [.medium(), .large()]
//            sheet.selectedDetentIdentifier = .large
//            sheet.largestUndimmedDetentIdentifier = .medium
//            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
//            sheet.prefersEdgeAttachedInCompactHeight = true
//            sheet.prefersGrabberVisible = true
//            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
//            sheet.preferredCornerRadius = 12
//        }
//        present(navigationController, animated: true, completion: nil)
    }

    // MARK: - Followers

    // TODO: Add segment section -> followers and followings
    func presentFollowers(withUser user: ProfileDetailsDisplayModel?, shouldShowFollowers: Bool) {
        debugLog(self, #function)

        guard let destionation = factory?.followerList else { return }
        destionation.user = user
        destionation.shouldShowFollowers = shouldShowFollowers
        navigationController?.pushViewController(destionation, animated: true)
    }

    // MARK: - New Exhbt

    func presentNewExhbt(delegate: NewExhbtDelegate?) {
        debugLog(self, #function)

        guard let destination = factory?.newExhbt else { return }
        destination.delegate = delegate

        let navigationController = UINavigationController(rootViewController: destination)

        navigationController.modalPresentationStyle = .pageSheet

        if let sheet = navigationController.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.largestUndimmedDetentIdentifier = .medium
            sheet.prefersScrollingExpandsWhenScrolledToEdge = true
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.prefersGrabberVisible = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
        }

        present(navigationController, animated: true)
    }

    // MARK: - New Exhbt Setup

    func presentNewExhbtSetup(withAsset asset: CCAsset, exhbtType: ExhbtType, delegate: NewExhbtDelegate?) {
        debugLog(self, #function)
        guard let destination = factory?.newExhbtSetup else { return }
        destination.asset = asset
        destination.exhbtType = exhbtType
        destination.delegate = delegate
        navigationController?.pushViewController(destination, animated: true)
    }

    // MARK: - Vote Styles

    func presentVoteStyles(on delegate: VoteStyleViewerDelegate) {
        debugLog(self, #function)
        guard let destination = factory?.voteStyleViewer else { return }
        destination.delegate = delegate
        destination.modalTransitionStyle = .crossDissolve
        destination.modalPresentationStyle = .overFullScreen
        present(destination, animated: true)
    }

    // MARK: - Photo

    func presentNotifications() {
        debugLog(self, #function)

        guard let notifications = factory?.notifications else { return }
        let navigationController = UINavigationController(rootViewController: notifications)
        present(navigationController, animated: true)
    }

    func presentNewCompetitionStatus(withType type: NewCompetitionStatusType, fromSource source: UIViewController) {
        debugLog(self, #function)

        guard let destination = factory?.newCompetitionStatus else { return }
        destination.type = type
        destination.delegate = source as? NewCompetitionStatusDelegate
        destination.modalTransitionStyle = .crossDissolve
        destination.modalPresentationStyle = .overCurrentContext
        present(destination, animated: true)
    }

    func presentChooseCompetitors(exhbtId: Int, delegate: ChooseCompetitorsDelegate?) {
        debugLog(self, #function)

        guard let destination = factory?.chooseCompetitors else { return }
        destination.exhbtId = exhbtId
        destination.delegate = delegate
        let destinationNavigationController = UINavigationController(rootViewController: destination)
        present(destinationNavigationController, animated: true)
    }

    func presentCompetitionsInfoPopup() {
        debugLog(self, #function)

        guard let destination = factory?.competitionsInfoPopup else { return }
        destination.modalPresentationStyle = .pageSheet

        if let sheet = destination.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.largestUndimmedDetentIdentifier = .large
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.prefersGrabberVisible = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
        }
        present(destination, animated: true, completion: nil)
    }

    func presentFollows(forUser userId: Int?) {
        debugLog(self, #function)
        guard let destination = factory?.follows else { return }
        navigationController?.pushViewController(destination, animated: true)
    }

    func presentNewExhbtPopup(exhbtId: Int, exhbtType: ExhbtType, delegate: NewExhbtDelegate?) {
        debugLog(self, #function)

        guard let destination = factory?.newExhbtPopup else { return }
        destination.exhbtId = exhbtId
        destination.exhbtType = exhbtType
        destination.delegate = delegate
        destination.modalPresentationStyle = .pageSheet

        if let sheet = destination.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.selectedDetentIdentifier = .medium
            sheet.largestUndimmedDetentIdentifier = .medium
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.prefersGrabberVisible = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            sheet.preferredCornerRadius = 12
        }
        present(destination, animated: true, completion: nil)
    }

    func presentMissingAccountDetails() {
        debugLog(self, #function)

        guard let destination = factory?.missingAccountDetails else { return }

        if let navigationController {
            navigationController.pushViewController(destination, animated: true)

        } else {
            let navigationController = UINavigationController(rootViewController: destination)
            navigationController.modalTransitionStyle = .crossDissolve
            navigationController.modalPresentationStyle = .fullScreen

            present(navigationController, animated: true)
        }
    }

    func presentSettings() {
        guard let destination = factory?.settings else { return }
        destination.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(destination, animated: true)
    }

    func presentProfileAccount() {
        guard let destination = factory?.profileAccount else { return }
        navigationController?.pushViewController(destination, animated: true)
    }

    func presentNotificationSettings() {
        guard let destination = factory?.notificationSettings else { return }
        navigationController?.pushViewController(destination, animated: true)
    }

    func presentDownloadData() {
        guard let destination = factory?.downloadData else { return }
        navigationController?.pushViewController(destination, animated: true)
    }

    func presentReportBug() {
        guard let destination = factory?.reportBug else { return }
        navigationController?.pushViewController(destination, animated: true)
    }

    func presentUpdateProfile(profileFieldType: UpdateProfileFieldType) {
        guard let destionation = factory?.updateProfile else { return }
        destionation.fieldType = profileFieldType
        navigationController?.pushViewController(destionation, animated: true)
    }

    func presentSafareViewController(url: String) {
        if let url = URL(string: url) {
            let safariViewController = SFSafariViewController(url: url)
            present(safariViewController, animated: true, completion: nil)
        }
    }

    func presentGalleryVertical(_ items: [GalleryDisplayModel], selected: Int = 0) {
        guard let destination = factory?.galleryVertical else { return }
        destination.items = items
        destination.selected = selected
        destination.modalTransitionStyle = .crossDissolve
        destination.modalPresentationStyle = .fullScreen
        present(destination, animated: true)
    }

    func presentUser(withId id: Int) {
        guard let destionation = factory?.user else { return }
        destionation.userId = id
        navigationController?.pushViewController(destionation, animated: true)
    }

    // MARK: - Sign In

    func presentSignIn() {
        debugLog(self, #function)

        guard let signIn = AppAssembler.shared.assembler?.resolver.resolve(SigninViewController.self) else { return }
        let navigationController = UINavigationController(rootViewController: signIn)
        navigationController.modalTransitionStyle = .crossDissolve
        navigationController.modalPresentationStyle = .fullScreen

        present(navigationController, animated: true)
    }

    // MARK: - Tab Bar

    func presentTabBar() {
        debugLog(self, #function)

        guard let tabBar = AppAssembler.shared.assembler?.resolver.resolve(TabBarViewController.self) else { return }
        tabBar.modalTransitionStyle = .crossDissolve
        tabBar.modalPresentationStyle = .fullScreen

        present(tabBar, animated: true)
    }

    // MARK: - Votes

    func presentVotes(withUser userId: Int? = nil) {
        debugLog(self, #function)

        guard let votes = factory?.votes else { return }
        votes.userId = userId
        navigationController?.pushViewController(votes, animated: true)
    }

    // MARK: - Voting

    func presentVoting(withExhbt exhbt: FeedPreviewDisplayModel, delegate: VotingDelegate? = nil) {
        debugLog(self, #function)

        guard let voting = factory?.voting else { return }
        voting.feed = exhbt
        voting.delegate = delegate
        voting.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        voting.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(voting, animated: true)
    }

    // MARK: - Explore Search

    func presentExploreSearch(searchQuery: String, category: Category) {
        guard let exploreSearch = factory?.exploreSearch else { return }
        exploreSearch.category = category
        exploreSearch.searchQuery = searchQuery
        exploreSearch.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(exploreSearch, animated: true)
    }

    // MARK: - Single Event

    func presentEvent(eventId: Int) {
        debugLog(self, #function)

        guard let destination = factory?.event else { return }
        destination.eventId = eventId
        destination.hidesBottomBarWhenPushed = true

        navigationController?.pushViewController(destination, animated: true)
    }

    // MARK: - Event Details

    func presentEventResult(eventId: Int) {
        debugLog(self, #function)

        guard let destination = factory?.eventResult else { return }
        destination.eventId = eventId
        destination.hidesBottomBarWhenPushed = true

        navigationController?.pushViewController(destination, animated: true)
    }

    // MARK: - Locations

    func presentLocations(delegate: LocationsDelegate?) {
        guard let destination = factory?.locations else { return }
        destination.delegate = delegate
        destination.modalPresentationStyle = .pageSheet

        if let sheet = destination.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.selectedDetentIdentifier = .medium
            sheet.largestUndimmedDetentIdentifier = .medium
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.prefersGrabberVisible = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            sheet.preferredCornerRadius = 32
        }
        present(destination, animated: true, completion: nil)
    }

    // MARK: - New Post

    func presentNewPost(event: EventDisplayModel?) {
        debugLog(self, #function)

        guard let destination = factory?.newPost else { return }
        destination.event = event
        let destinationNavigationController = UINavigationController(rootViewController: destination)
        present(destinationNavigationController, animated: true)
    }

    // MARK: - Post

    func presentPosts(forEvent event: Int) {
        debugLog(self, #function)

        guard let destination = factory?.posts else { return }
        destination.eventId = event
        destination.hidesBottomBarWhenPushed = true

        navigationController?.pushViewController(destination, animated: true)
    }

    // MARK: - Prizes

    func presentPrizes(forUser userId: Int) {
        debugLog(self, #function)

        guard let destination = factory?.prizes else { return }
        destination.userId = userId

        navigationController?.pushViewController(destination, animated: true)
    }
}

// MARK: - Alerts

extension Router where Self: UIViewController {
    func displayIneligibilityAlert(message: String, completion: @escaping (() -> Void)) {
        let alertController = UIAlertController(title: "Oops, not enough coins to create", message: message, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancelAction)

        let okAction = UIAlertAction(title: "Play Flash", style: .default) { _ in
            completion()
        }
        alertController.addAction(okAction)

        present(alertController, animated: true)
    }

    func displayAlert(withTitle title: String?, message: String?, completion: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let confirm = UIAlertAction(title: "OK", style: .cancel) { _ in
            completion?()
        }
        alertController.addAction(confirm)
        present(alertController, animated: true)
    }

    func displayWarningAlert(withTitle title: String?, message: String?, completion: @escaping (() -> Void)) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let confirm = UIAlertAction(title: "Confirm", style: .destructive) { _ in
            completion()
        }
        alertController.addAction(confirm)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alertController, animated: true)
    }

    func presentContent(_ model: ExhbtPreviewDisplayModel) {
        guard let destination = factory?.exhbtContent else { return }
        destination.model = model
        navigationController?.pushViewController(destination, animated: true)
    }

    // MARK: - New Event

    func presentNewEvent() {
        guard let destination = factory?.newEvent else { return }

        let navigationController = UINavigationController(rootViewController: destination)
        navigationController.modalPresentationStyle = .pageSheet

        if let sheet = navigationController.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.largestUndimmedDetentIdentifier = .medium
            sheet.prefersScrollingExpandsWhenScrolledToEdge = true
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.prefersGrabberVisible = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
        }
        present(navigationController, animated: true)
    }

    // MARK: Present Invite

    func presentInvite(eventId: Int) {
        guard let destination = factory?.invite else { return }
        destination.eventId = eventId
        let destinationNavigationController = UINavigationController(rootViewController: destination)
        present(destinationNavigationController, animated: true)
    }
}
