//
//  InviteToCompetitionViewController.swift
//  Exhbt
//
//  Created by Steven Worrall on 5/3/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import UIKit
import Lottie

class InviteToCompetitionViewController: UIViewController {
    private let competition: CompetitionDataModel
    private let inviteInteractor = InviteInteractor()
    private let userDefaultsRepo = UserDefaultsRepository()
    
    private var allUsers: [User] = []
    private var shownUsers: [User] = []
    private var fragmentedUsers: [Character: [User]] = [:]
    private var letters: [Character] = []
    
    private let cellID = "inviteCellID"
    private let viewPadding: CGFloat = 16
    private var invitedUsers: [String] = []
    
    lazy var tableView: UITableView = {
        let temp = UITableView(frame: .zero, style: UITableView.Style.plain)
        temp.backgroundColor = .clear
        temp.separatorStyle = .none
        temp.tableFooterView = UIView()
        temp.rowHeight = UITableView.automaticDimension
        temp.estimatedRowHeight = UITableView.automaticDimension
        return temp
    }()
    
    private let titleLabel = Label(title: "Invite friends to contest", fontSize: 24, weight: .bold)
    private let subtitleLabel = Label(title: "Choose up to 3 other friends to challenge", fontSize: 18)
    
    private lazy var searchField: UITextField = {
        let temp = UITextField()
        temp.placeholder = "search"
        temp.textColor = .DarkGray()
        temp.autocapitalizationType = .none
        temp.layer.borderColor = UIColor.DarkGray().cgColor
        temp.layer.borderWidth = 1
        temp.layer.cornerRadius = 4
        temp.font = UIFont(name: "Helvetica Neue", size: 16)
        temp.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        temp.delegate = self
        temp.returnKeyType = .done
        return temp
    }()
    
    private lazy var inviteButton: Button = {
        let button = PrimaryButton(title: "Invite friends")
        button.addAction(#selector(inviteTap), for: self)
        return button
    }()
    
    private lazy var createButton: Button = {
        let button = PrimaryButton(title: "Create competition")
        button.addAction(#selector(createTap), for: self)
        return button
    }()
    
    var isSearching: Bool {
        return getTextFieldText(searchField) != nil
    }
    
    var shouldPresentExternalInvite: Bool = false
    var createTapped: Bool = false
    
    init(data: CompetitionDataModel) {
        self.competition = data
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Skip", style: .plain, target: self, action: #selector(onSkipTap))
        
        self.inviteInteractor.delegate = self
        self.inviteInteractor.getFollowing()
        self.setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if shouldPresentExternalInvite {
            presentExternalInviteController()
        }
    }
    
    private func presentExternalInviteController() {
        let controller = ExternalInviteViewController(competitionID: competition.competitionID)
        present(controller, animated: true)
    }
    
    private func setupViews() {
        setupTitle()
        setupSubtitle()
        setupSearchField()
        setupInviteButton()
        setupTableView()
        setupCreateButton()
    }
    
    private func setupTitle() {
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().inset(viewPadding)
            make.top.equalToSuperview().inset(24)
        }
    }
    
    private func setupSubtitle() {
        view.addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().inset(viewPadding)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
        }
    }
    private func setupSearchField() {
        view.addSubview(searchField)
        searchField.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview().inset(viewPadding)
            make.top.equalTo(subtitleLabel.snp.bottom).offset(12)
            make.height.equalTo(40)
        }
        searchField.setLeftPadding(by: viewPadding)
    }
    
    private func setupInviteButton() {
        inviteButton.layer.cornerRadius = 22
        
        self.view.addSubview(inviteButton)
        inviteButton.snp.makeConstraints { (make) in
            make.top.equalTo(searchField.snp.bottom).offset(viewPadding)
            make.width.equalTo(180)
            make.height.equalTo(44)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setupTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self

        tableView.register(InvitePeopleCell.self, forCellReuseIdentifier: cellID)
        
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(inviteButton.snp.bottom).offset(viewPadding)
        }
    }
    
    private func setupCreateButton() {
        self.view.addSubview(createButton)
        createButton.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(24)
            make.height.equalTo(Button.bigHeight)
            make.centerX.equalToSuperview()
            make.top.equalTo(tableView.snp.bottom).offset(16)
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let text = getTextFieldText(textField) else {
            shownUsers = allUsers
            reloadUserTable()
            return
        }
        
        shownUsers = allUsers.filter {
            return $0.name?.lowercased().contains(text.lowercased()) ?? false
        }
        reloadUserTable()
    }
    
    private func getTextFieldText(_ field: UITextField) -> String? {
        guard let text = searchField.text, !text.isEmpty, text != "" else {
            return nil
        }
        return text
    }
    
    @objc private func onSkipTap(sender: UIBarButtonItem) {
        inviteAndExit(skip: true)
    }
    
    @objc func inviteTap() {
        presentInviteActivity(competitionID: competition.competitionID, completion: {
            [weak self] in
            guard let self = self else { return }
            
            let animationView = AnimationView(name: "PlusFiveCoins")
            self.view.addSubview(animationView)
            animationView.snp.makeConstraints { (make) in
                make.width.height.equalToSuperview().multipliedBy(2)
                make.center.equalToSuperview()
            }
            
            animationView.play(completion: { finished in
                animationView.removeFromSuperview()
            })
            self.inviteInteractor.addCoinsForExternalInvite(creatorID: self.competition.creatorID)
        })
    }
    
    @objc func createTap() {
        guard !createTapped else { return }
        createTapped = true
        inviteAndExit(skip: false)
    }
    
    private func inviteAndExit(skip: Bool) {
        guard invitedUsers.count > 0 ||  skip else {
            presentAlert(title: "", message: "Challenge at least one person!")
            createTapped = false
            return
        }

        CompetitionUploadManager.shared.createCompetition(competition: competition)

        inviteInteractor.sendInvites(for: invitedUsers, competition: competition)

        if userDefaultsRepo.getBool(for: .hasCreatedACompetition) == false {
            exitFromForcedCreate()
            return
        }
        // need to set this before popping to root or onCreateCompetition never happens
        // because the view controller immediately deinitializes
        let tabBar = self.tabBarController as? TabBarController
        
        navigationController?.popToRootViewController(animated: false)
        tabBar?.onCreateCompetition()
    }
    
    private func exitFromForcedCreate() {
        userDefaultsRepo.setBool(true, for: .hasCreatedACompetition)
        let tabBar = (navigationController?.presentingViewController as? UINavigationController)?.topViewController as? TabBarController
        tabBar?.selectedIndex = 0
        navigationController?.dismiss(animated: true, completion: {
            tabBar?.onCreateCompetition()
        })
    }
    
    private func reloadUserTable() {
        self.tableView.reloadData()
    }
}

extension InviteToCompetitionViewController: InviteInteractorDelegate {
    func didReceiveFollowing(users: [User]) {
        self.allUsers = users
        self.shownUsers = users
        
        let sortedUsers = users.sorted {
            guard let name1 = $0.name, let name2 = $1.name else { return true }
            return name1.lowercased() < name2.lowercased()
        }
        
        guard allUsers.count > 0,
            var firstLetter = sortedUsers.first?.name?.first?.toUpper() else {
                shouldPresentExternalInvite = true
                return
        }

        letters = [firstLetter]
        fragmentedUsers[firstLetter] = []
        
        sortedUsers.forEach { user in
            guard let newFirstLetter = user.name?.first?.toUpper() else { return }
            if newFirstLetter == firstLetter {
                fragmentedUsers[firstLetter]?.append(user)
            } else {
                firstLetter = newFirstLetter
                fragmentedUsers[firstLetter] = [user]
                letters.append(firstLetter)
            }
        }
        letters = letters.sorted()
    
        self.reloadUserTable()
    }
    
    func errorRecievingData(error: Error) {
        // todo add eroror state here
        self.allUsers = []
        self.shownUsers = []
        self.reloadUserTable()
    }
}

extension InviteToCompetitionViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if isSearching {
            return 1
        }
        return letters.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return shownUsers.count
        }
        return fragmentedUsers[letters[section]]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection
        section: Int) -> String? {
        if isSearching {
            return nil
        }
        return String(letters[section])
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID) as? InvitePeopleCell else {
            return UITableViewCell()
        }
        
        cell.selectionStyle = .none
        if isSearching {
            cell.user = shownUsers[indexPath.row]
            return cell
        }
        
        let letter = letters[indexPath.section]
        guard let users = fragmentedUsers[letter] else { return UITableViewCell() }
        
        cell.user = users[indexPath.row]
        cell.delegate = self
        
        return cell
    }
}

extension InviteToCompetitionViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension InviteToCompetitionViewController: InviteCellDelegate {
    func challengePressed(isSelected: Bool, user: User) {
        if isSelected {
            invitedUsers.append(user.userID)
        } else {
            for (index, item) in invitedUsers.enumerated() {
                if user.userID == item {
                    invitedUsers.remove(at: index)
                    break
                }
            }
        }
        print("invited users \(self.invitedUsers)")
    }
}
