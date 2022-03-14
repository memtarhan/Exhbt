//
//  SearchTableView.swift
//  Exhbt
//
//  Created by Shouvik Paul on 10/18/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import UIKit

class SearchController: UIViewController {
    var allUsers: [User] = []
    var shownUsers: [User] = []
    var recentSearches: [RecentSearch] = []
    
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
    
    let recentSearchesView = UIView()
    
    lazy var recentSearchesTableView: UITableView = {
        let temp = UITableView(frame: .zero, style: UITableView.Style.plain)
        temp.backgroundColor = .clear
        temp.separatorStyle = .none
        temp.tableFooterView = UIView()
        temp.rowHeight = UITableView.automaticDimension
        temp.estimatedRowHeight = UITableView.automaticDimension
        temp.delegate = self
        temp.dataSource = self
        temp.register(RecentSearchCell.self, forCellReuseIdentifier: NSStringFromClass(RecentSearchCell.self))
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
    
    let interactor = SearchInteractor()
    
    var isSearching: Bool {
        return getTextFieldText(searchField) != nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        interactor.delegate = self
        interactor.getAllUsers()
        recentSearches = interactor.getRecentSearches()
        setupView()
    }
    
    private func setupView() {
        setupSearchField()
        setupRecentSearches()
        setupUsersTableView()
        
        recentSearchesTableView.reloadData()
        if recentSearches.count == 0 {
            recentSearchesView.isHidden = true
        } else {
            usersTableView.isHidden = true
        }
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
    
    private func setupRecentSearches() {
        recentSearchesView.backgroundColor = .white
        view.addSubview(recentSearchesView)
        recentSearchesView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(searchField.snp.bottom).offset(16)
            make.bottom.equalToSuperview().priority(.low)
        }
        let label = Label(title: "Recent", fontSize: 18, weight: .bold)
        recentSearchesView.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.left.equalToSuperview().inset(8)
            make.top.equalToSuperview()
        }
        
        recentSearchesTableView.backgroundColor = .white
        recentSearchesView.addSubview(recentSearchesTableView)
        recentSearchesTableView.snp.makeConstraints { (make) in
            make.top.equalTo(label.snp.bottom)
            make.left.right.bottom.equalToSuperview().inset(16)
        }
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
            usersTableView.isHidden = true
            recentSearchesView.isHidden = false
            return
        }
        
        shownUsers = allUsers.filter {
            return $0.name?.lowercased().contains(text.lowercased()) ?? false
        }
        usersTableView.reloadData()
        
        if usersTableView.isHidden {
            recentSearchesView.isHidden = true
            usersTableView.isHidden = false
        }
    }
    
    private func getTextFieldText(_ field: UITextField) -> String? {
        guard let text = searchField.text, !text.isEmpty, text != "" else {
            return nil
        }
        return text
    }
}

extension SearchController: SearchInteractorDelegate {
    func didReceiveAllUsers(_ users: [User]) {
        self.allUsers = users
        self.shownUsers = users
        
        DispatchQueue.main.async {
            self.usersTableView.reloadData()
        }
    }
    
    func errorReceivingAllUsers(_ error: Error) {
        // TODO: handle error?
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

extension SearchController: RecentSearchCellDelegate {
    func hideRecentSearch(_ search: RecentSearch) {
        interactor.removeSearch(search)
        recentSearches = recentSearches.filter { return $0.userID != search.userID }
        recentSearchesTableView.reloadData()
    }
}

extension SearchController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (tableView == usersTableView) ? shownUsers.count : recentSearches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == usersTableView {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(InvitePeopleCell.self)) as? InvitePeopleCell else {
                return UITableViewCell()
            }
            
            cell.selectionStyle = .none
            cell.user = shownUsers[indexPath.row]
            cell.button.removeFromSuperview()
            return cell
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(RecentSearchCell.self)) as? RecentSearchCell else {
            return UITableViewCell()
        }

        cell.delegate = self
        cell.search = recentSearches[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == recentSearchesTableView {
            guard let cell = tableView.cellForRow(at: indexPath) as? RecentSearchCell,
                let search = cell.search else { return }
            
            interactor.getUser(by: search.userID)
        }
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
        interactor.saveRecentSearch(RecentSearch(userID: user.userID, name: user.name ?? ""))
        recentSearches = interactor.getRecentSearches()
        DispatchQueue.main.async {
            self.recentSearchesTableView.reloadData()
        }
    }
}

extension SearchController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
