//
//  NotificationController.swift
//  Exhbt
//
//  Created by Steven Worrall on 5/4/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import UIKit

enum NotificationArrayIndex: Int {
    case requests = 0
    case invites = 1
    case current = 2
    case results = 3
}

class NotificationController: UIViewController {
    private let user: User
    private let notificationInteractor = NotificationInteractor()
    private var notifications: [[Any]] = [[], [], [], []]
    private var loading: [Bool] = [true, true, true, true]
    
    private var isLoading: Bool {
        return (loading.filter { return $0 }).count > 1
    }
    
    private let refreshControl: UIRefreshControl = {
        let temp = UIRefreshControl()
        temp.backgroundColor = .white
        return temp
    }()
    
    private lazy var tableView: UITableView = {
        let temp = UITableView(frame: .zero, style: UITableView.Style.plain)
        temp.backgroundColor = .white
        temp.tableFooterView = UIView()
        temp.register(
            FollowRequestCell.self,
            forCellReuseIdentifier: NSStringFromClass(FollowRequestCell.self))
        temp.register(
            CompetitionInviteCell.self,
            forCellReuseIdentifier: NSStringFromClass(CompetitionInviteCell.self))
        temp.register(
            CurrentCompetitionCell.self,
            forCellReuseIdentifier: NSStringFromClass(CurrentCompetitionCell.self))
        temp.register(
            CompetitionResultCell.self,
            forCellReuseIdentifier: NSStringFromClass(CompetitionResultCell.self))
        temp.addSubview(self.refreshControl)
        self.refreshControl.addTarget(self, action: #selector(self.refreshTriggered(_:)), for: .valueChanged)
        temp.separatorStyle = .none
        return temp
    }()
    
    init(user: User) {
        self.user = user
        
        super.init(nibName: nil, bundle: nil)
        notificationInteractor.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getData()
        self.setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isLoading {
            refreshControl.beginRefreshing()
        }
    }
    
    private func getData() {
        notificationInteractor.getNotifications(for: user.userID)
        notificationInteractor.getCurrentCompetitions(competitionIDs: user.currentCompetitionIDs)
    }
    
    private func setupView() {
        self.view.backgroundColor = .white
        setNavigationTitleView()

        self.setupTableView()
    }
    
    @objc func refreshTriggered(_ send: Any) {
        refreshControl.beginRefreshing()
        notifications = [[], [], [], []]
        loading = [true, true, true, true]
        getData()
    }
}

extension NotificationController: NotificationInteractorDelegate {
    func didReceiveNotifications(
        _ notifications: [Any],
        index: NotificationArrayIndex) {
        self.notifications[index.rawValue] = notifications
        print("notifs for index: \(index) notifs: \(notifications)")
        tableView.reloadData()
        
        loading[index.rawValue] = false
        if !isLoading {
            refreshControl.endRefreshing()
        }
    }
    
    func errorReceivingNotifications(_ error: Error, index: NotificationArrayIndex) {
        print("error getting \(index) notifs: \(error)")
        loading[index.rawValue] = false
    }
    
    func didRecieveCurrentCompetitions(_ currentCompetitions: [CompetitionDataModel]) {
        self.notifications[NotificationArrayIndex.current.rawValue] = currentCompetitions
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
}

extension NotificationController: UITableViewDelegate, UITableViewDataSource {
    private func setupTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview().inset(24)
            make.top.equalTo(view.safeAreaLayoutGuide).inset(24)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications[section].count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if notifications[section].count == 0 {
            return UIView()
        }
        var text: String
        
        if section == NotificationArrayIndex.requests.rawValue {
            text = "Requests"
        } else if section == NotificationArrayIndex.invites.rawValue {
            text = "Challenge invitations"
        } else if  section == NotificationArrayIndex.current.rawValue {
            text = "In progress"
        } else {
            text = "Results"
        }
        let label = Label(title: text, fontSize: 18, weight: .bold)
        let headerView = UIView()
        headerView.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.top.left.equalToSuperview()
            make.bottom.equalToSuperview().inset(16)
        }

        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == NotificationArrayIndex.requests.rawValue {
            return createFollowRequestCell(tableView, indexPath: indexPath)
        } else if  indexPath.section == NotificationArrayIndex.invites.rawValue {
            return createInviteCell(tableView, indexPath: indexPath)
        } else if  indexPath.section == NotificationArrayIndex.current.rawValue {
            return createCurrentCompetitionCell(tableView, indexPath: indexPath)
        } else if indexPath.section == NotificationArrayIndex.results.rawValue {
            return createCompetitionResultCell(tableView, indexPath: indexPath)
        }
        return UITableViewCell()
    }
    
    func createFollowRequestCell(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
                withIdentifier: NSStringFromClass(FollowRequestCell.self),
                for: indexPath) as? FollowRequestCell,
              let notificaiton = notifications[NotificationArrayIndex.requests.rawValue][indexPath.row] as? Notification,
              let user = notificaiton.creator else {
            return UITableViewCell()
        }
        
        cell.delegate = self
        cell.set(user: user)
        
        return cell
    }
    
    func createInviteCell(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
                withIdentifier: NSStringFromClass(CompetitionInviteCell.self),
                for: indexPath) as? CompetitionInviteCell,
              let notificaiton = notifications[NotificationArrayIndex.invites.rawValue][indexPath.row] as? Notification else {
            return UITableViewCell()
        }
        
        cell.delegate = self
        cell.set(notif: notificaiton)
        
        return cell
    }
    
    func createCurrentCompetitionCell(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
                withIdentifier: NSStringFromClass(CurrentCompetitionCell.self),
                for: indexPath) as? CurrentCompetitionCell,
              let comp = notifications[NotificationArrayIndex.current.rawValue][indexPath.row] as? CompetitionDataModel else {
            return UITableViewCell()
        }
        
        cell.set(competition: comp)
        
        return cell
    }
    
    func createCompetitionResultCell(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
                withIdentifier: NSStringFromClass(CompetitionResultCell.self),
                for: indexPath) as? CompetitionResultCell,
              let result = notifications[NotificationArrayIndex.results.rawValue][indexPath.row] as? CompetitionResultNotification else {
            return UITableViewCell()
        }
        
        cell.set(result: result)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableView.automaticDimension
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == NotificationArrayIndex.requests.rawValue {
            showUser(notifications[indexPath.section][indexPath.row] as? Notification)
        } else if indexPath.section == NotificationArrayIndex.invites.rawValue {
            return
        } else if indexPath.section == NotificationArrayIndex.current.rawValue {
            let comp = notifications[indexPath.section][indexPath.row] as? CompetitionDataModel
            presentCompetition(competitionID: comp?.competitionID)
        } else if indexPath.section == NotificationArrayIndex.results.rawValue {
            let result = notifications[indexPath.section][indexPath.row] as? CompetitionResultNotification
            showCompetition(result?.notification)
        }
    }
    
    func showCompetition(_ notification: Notification?) {
        guard let competitionID = notification?.competitionID else {
            presentAlert(title: "Error", message: "Sorry, there was an issue getting the competition.")
            return
        }
        presentCompetition(competitionID: competitionID)
    }
    
    private func presentCompetition(competitionID: String?) {
        guard let competitionID = competitionID else {
            presentAlert(title: "Error", message: "Sorry, there was an issue getting the competition.")
            return
        }
        let voteVC = NewsfeedVoteController(competitionID: competitionID, fromNewsFeed: false)
        present(voteVC, animated: true)
    }

    func showUser(_ notification: Notification?) {
        guard let creator = notification?.creator else{
            presentAlert(title: "Error", message: "Sorry, there was an issue getting the user.")
            return
        }
        let controller = ProfileController(user: creator)
        present(controller, animated: true)
    }
}

extension NotificationController: CompetitionInviteCellDelegate {
    func goToInvite(from notification: Notification) {
        guard let competitionID = notification.competitionID else {
            presentAlert(title: "Error", message: "Sorry, there was an issue getting the competition.")
            return
        }
        let controller = InvitationController(competitionID: competitionID)
        let navVC = NavController(rootViewController: controller)
        navVC.modalPresentationStyle = .fullScreen
        present(navVC, animated: true)
    }
    
    func deleteCompetitionInvite(notification: Notification) {
        notificationInteractor.deleteCompetitionInvite(for: notification)
        if let invites = notifications[NotificationArrayIndex.invites.rawValue] as? [Notification] {
            notifications[NotificationArrayIndex.invites.rawValue] = invites.filter { note in
                if let compID1 = notification.competitionID, let compID2 = note.competitionID {
                    return compID1 != compID2
                }
                return true
            }
        }
        tableView.reloadData()
    }
}

extension NotificationController: FollowRequestCellDelegate {
    func deleteFollowRequest(from userID: String) {
        notificationInteractor.deleteFollowRequest(from: userID, followUserID: user.userID)
        if let requests = notifications[NotificationArrayIndex.results.rawValue] as? [Notification] {
            notifications[NotificationArrayIndex.results.rawValue] = requests.filter { note in
                return note.creatorID != userID
            }
        }
        tableView.reloadData()
    }
    
    func acceptFollowRequest(from userID: String) {
        notificationInteractor.acceptFollowRequest(from: userID, followUserID: user.userID)
        if let requests = notifications[NotificationArrayIndex.results.rawValue] as? [Notification] {
            notifications[NotificationArrayIndex.results.rawValue] = requests.filter { note in
                return note.creatorID != userID
            }
        }
        tableView.reloadData()
    }
}
