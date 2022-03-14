//
//  TabBarController.swift
//  Exhbt
//
//  Created by Steven Worrall on 4/8/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import UIKit

enum DeepLink {
    case invite(String)
    case competition(String)
    case user(String)
}

class TabBarController: UITabBarController {
    let userManager = UserManager.shared
    let competitionUploadManager = CompetitionUploadManager.shared
    let userDefaultsRepo = UserDefaultsRepository()
    
    var deepLink: DeepLink?
    var isVisible: Bool = false
    
    private lazy var appearance: UITabBarAppearance = {
        let temp = UITabBarAppearance()
        let redColor = UIColor.EXRed()
        temp.backgroundColor = UIColor.init(named: "MainDarkColor")
        temp.stackedLayoutAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        temp.stackedLayoutAppearance.normal.iconColor = UIColor.white
        temp.stackedLayoutAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: redColor]
        temp.stackedLayoutAppearance.selected.iconColor = redColor
        return temp
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userManager.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        isVisible = true
        routeToDeepLink()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        isVisible = false
    }

    func initialize() {
        guard let user = userManager.user else {
            tabBar.isHidden = true
            let authVC = AuthController()
            authVC.delegate = self
            viewControllers = [authVC]
            return
        }
        
        setupTabBar(user)
        routeToDeepLink()
    }
    
    func onCreateCompetition() {
        selectedIndex = 0
        present(PostCompetitionModal(), animated: true, completion: nil)
    }
    
    private func setupTabBar(_ user: User) {
        self.setupAppearance()
        self.setupControllers(user)
    }

    private func setupAppearance() {
        self.tabBar.isHidden = false
        self.tabBar.isTranslucent = false
        tabBar.standardAppearance = self.appearance
    }
    
    func routeToDeepLink() {
        guard let user = userManager.user, isVisible else {
            return
        }
        guard userDefaultsRepo.getBool(for: .hasSeenOnboarding) else {
            showOnboarding()
            return
        }
        guard userManager.hasCompletedProfile() else {
            showCompleteProfile(user)
            return
        }
        guard userDefaultsRepo.getBool(for: .hasCreatedACompetition) else {
            showCreateFlow()
            return
        }
        guard userDefaultsRepo.getBool(for: .hasRecievedInitalCoins) else {
            showDailyCoinModal(user)
            userDefaultsRepo.setBool(true, for: .hasRecievedInitalCoins)
            return
        }
        if let shouldDisplayModal = userManager.user?.shouldDisplayDailyModal() {
            if shouldDisplayModal {
                self.showDailyCoinModal(user)
            }
        }
        
        guard let deepLink = deepLink else { return }
        
        var controller: UIViewController?
        
        switch deepLink {
        case .invite(let id):
            print("deep link invite for competionID: \(id)")
            controller = InvitationController(competitionID: id)
        case .competition(let id):
            print("deep link to view competionID: \(id)")
            // TODO: route to competition page for competitionID = id
        case .user(let id):
            print("deep link to view userID: \(id)")
            // TODO: route to profile page for userID = id
        }
        
        if let controller = controller {
            let navVC = NavController(rootViewController: controller)
            navVC.modalPresentationStyle = .fullScreen
            present(navVC, animated: true)
        }
        self.deepLink = nil
    }
    
    private func setupControllers(_ user: User) {
        let firstVC = NewsfeedController()
//        self.competitionUploadManager.delegate = firstVC
        
        let firstVCNavController = NavController(rootViewController: firstVC)
        let firstTabBarItem = UITabBarItem(title: "Competitions", image: UIImage(named: "NewfeedTabBarIcon"), tag: 0)
        firstVCNavController.tabBarItem = firstTabBarItem
        
        let leaderBoard = LeaderboardController()
        let leaderBoardNVC = NavController(rootViewController: leaderBoard)
        let leaderBoardItem = UITabBarItem(title: "Leaderboard", image: UIImage(named: "LeaderboardTabBarIcon"), tag: 1)
        leaderBoardNVC.tabBarItem = leaderBoardItem
        
        let category = CategorySelectorViewController()
        let categoryNVC = NavController(rootViewController: category)
        let createItem = UITabBarItem(title: "Create", image: UIImage(named: "CreateTabBarIcon"), tag: 1)
        categoryNVC.tabBarItem = createItem
        
        let thirdVC = NotificationController(user: user)
        let thirdVCNavController = NavController(rootViewController: thirdVC)
        let thirdTabBarItem = UITabBarItem(title: "Notifications", image: UIImage(named: "NotificationTabBarIcon"), tag: 2)
        thirdVCNavController.tabBarItem = thirdTabBarItem
        
        let fourthVC = ProfileController(user: user)
        let fourthVCNavController = NavController(rootViewController: fourthVC)
        let fourthTabBarItem = UITabBarItem(title: "Profile", image: UIImage(named: "ProfileTabBarIcon"), tag: 3)
        fourthVCNavController.tabBarItem = fourthTabBarItem
        
        self.viewControllers = [firstVCNavController, leaderBoardNVC, categoryNVC, thirdVCNavController, fourthVCNavController]
        
        self.selectedIndex = 0
    }
    
    private func showOnboarding() {
        guard isVisible else { return }

        userDefaultsRepo.setBool(true, for: .hasSeenOnboarding)
        let onboardingVC = OnboardingController()
        onboardingVC.modalPresentationStyle = .fullScreen
        present(onboardingVC, animated: true)
    }
    
    private func showCompleteProfile(_ user: User) {
        guard isVisible else { return }

        let editVC = EditProfileController(user: User(user: user))
        let navVC = NavController(rootViewController: editVC)
        navVC.modalPresentationStyle = .fullScreen
        present(navVC, animated: true)
    }
    
    private func showCreateFlow() {
        guard isVisible else { return }
        
        let category = CategorySelectorViewController()
        let navVC = NavController(rootViewController: category)
        navVC.modalPresentationStyle = .overFullScreen
        present(navVC, animated: true)
    }
    
    private func showDailyCoinModal(_ user: User) {
        let controller = DailyCoinModal(user: user)
        present(controller, animated: true)
    }
    
    private func animateIntialization() {
        UIView.animate(withDuration: 0.3, animations: {
            self.view.alpha = 0
        }) { _ in
            self.initialize()
            self.view.alpha = 1
        }
    }
}

extension TabBarController: AuthControllerDelegate {
    func authSuccess(_ user: User, for authFlow: AuthFlow) {
        animateIntialization()
    }
}

extension TabBarController: UserManagerDelegate {
    func loggedOut() {
        animateIntialization()
    }
}
