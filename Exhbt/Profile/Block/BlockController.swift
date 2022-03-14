//
//  BlockController.swift
//  Exhbt
//
//  Created by Shouvik Paul on 1/19/21.
//  Copyright © 2021 Exhbt LLC. All rights reserved.
//

import UIKit

class BlockController: UIViewController {
    var allUsers: [User] = []
    var shownUsers: [User] = []
    
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
    
    lazy var usersTableView: UITableView = {
        let temp = UITableView(frame: .zero, style: UITableView.Style.plain)
        temp.backgroundColor = .clear
        temp.separatorStyle = .none
        temp.tableFooterView = UIView()
        temp.rowHeight = UITableView.automaticDimension
        temp.estimatedRowHeight = UITableView.automaticDimension
        temp.delegate = self
        temp.dataSource = self
        temp.register(InvitePeopleCell.self, forCellReuseIdentifier: NSStringFromClass(InvitePeopleCell.self))
        return temp
    }()
    
    let interactor = BlockInteractor()
    
    var isSearching: Bool {
        return getTextFieldText(searchField) != nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        interactor.delegate = self
        interactor.getAllUsers()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let blockedIDs = UserManager.shared.blockedUsers.map { return $0.blockedID }
        allUsers = allUsers.map { (user: User) -> User in
            user.selected = blockedIDs.contains(user.userID)
            return user
        }
        allUsers = allUsers.sorted {
            if $0.selected { return true }
            if $1.selected { return false }
            return true
        }
        
        usersTableView.reloadData()
    }

    private func setupView() {
        setupSearchField()
        setupUsersTableView()
    }
    
    private func setupSearchField() {
        view.addSubview(searchField)
        searchField.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalToSuperview().offset(12)
            make.height.equalTo(40).priority(.low)
        }
        searchField.setLeftPadding(by: 16)
    }
    
    private func setupUsersTableView() {
        self.view.addSubview(self.usersTableView)
        self.usersTableView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(searchField.snp.bottom).offset(16)
            make.bottom.equalToSuperview().priority(.low)
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let text = getTextFieldText(textField) else {
            shownUsers = allUsers
            usersTableView.reloadData()
            return
        }
        
        shownUsers = allUsers.filter {
            return $0.name?.lowercased().contains(text.lowercased()) ?? false
        }
        usersTableView.reloadData()
    }
    
    private func getTextFieldText(_ field: UITextField) -> String? {
        guard let text = searchField.text, !text.isEmpty, text != "" else {
            return nil
        }
        return text
    }
}

extension BlockController: BlockInteractorDelegate {
    func didReceiveAllUsers(_ users: [User]) {
        self.allUsers = users
        self.shownUsers = users
        DispatchQueue.main.async {
            self.usersTableView.reloadData()
        }
    }
    
    func didReceiveUser(_ user: User) {
        removeLoadingScreen()
        presentUser(user)
    }
    
    func errorReceivingUser(_ error: Error) {
        removeLoadingScreen()
        presentAlert(title: "Error", message: "Sorry we could not find the user at this time. Please try again later.")
    }
}

extension BlockController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shownUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(InvitePeopleCell.self)) as? InvitePeopleCell else {
            return UITableViewCell()
        }
        
        let user = shownUsers[indexPath.row]
        cell.selectionStyle = .none
        cell.user = user
        cell.button.removeFromSuperview()
        cell.label.textColor = (user.selected) ? .red : .DarkGray()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? InvitePeopleCell,
              let user = cell.user else { return }
        
        presentUser(user)
    }
    
    private func presentUser(_ user: User) {
        let profileVC = ProfileController(user: user)
        var navVC: UINavigationController? = navigationController
        if navVC == nil {
            navVC = parent?.navigationController
        }
        if let navVC = navVC {
            navVC.pushViewController(profileVC, animated: true)
        } else {
            present(profileVC, animated: true)
        }
    }
}

extension BlockController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
