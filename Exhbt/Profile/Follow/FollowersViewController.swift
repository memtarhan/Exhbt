//
//  FollowersViewController.swift
//  Exhbt
//
//  Created by Steven Worrall on 11/27/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import UIKit

class FollowersViewController: UIViewController {
    let user: User
    var followers: [User] = []
    
    let followersInteractor = FollowersInteractor()
    
    let emptyView = UIView()
    lazy var emptyLabel = Label(title: "\(String(describing: user.name ?? "User")) has no followers...", fontSize: 22, weight: .regular)
    
    private lazy var tableView: UITableView = {
        let temp = UITableView(frame: .zero, style: UITableView.Style.plain)
        temp.backgroundColor = .clear
        temp.separatorStyle = .none
        temp.tableFooterView = UIView()
        temp.rowHeight = UITableView.automaticDimension
        temp.estimatedRowHeight = UITableView.automaticDimension
        temp.addSubview(self.refreshControl)
        self.refreshControl.addTarget(self, action: #selector(self.getData), for: .valueChanged)
        temp.register(InvitePeopleCell.self, forCellReuseIdentifier: NSStringFromClass(InvitePeopleCell.self))
        return temp
    }()
    
    private let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupView()
    }

    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
        
        self.getData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.followersInteractor.delegate = self
        self.view.backgroundColor = .white
        
        self.setupTableView()
        self.setupEmptyState()
    }
    
    private func setupEmptyState() {
        self.emptyLabel.textAlignment = .center
        self.emptyView.isHidden = true
        
        self.view.addSubview(self.emptyView)
        self.emptyView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        self.emptyView.addSubview(self.emptyLabel)
        self.emptyLabel.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(40)
        }
    }
    
    @objc private func getData() {
        self.refreshControl.beginRefreshing()
        self.followersInteractor.getFollowers(for: self.user.userID)
    }
    
    private func reloadViews() {
        self.tableView.reloadData()
    }
    
    func checkToHideEmptyState() {
        if followers.isEmpty {
            self.emptyView.isHidden = false
        } else {
            self.emptyView.isHidden = true
        }
    }
}

extension FollowersViewController: UITableViewDelegate, UITableViewDataSource {
    private func setupTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(20)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.followers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(InvitePeopleCell.self)) as? InvitePeopleCell else {
            return UITableViewCell()
        }
        
        cell.selectionStyle = .none
        cell.user = self.followers[indexPath.row]
        cell.button.removeFromSuperview()
        return cell
    }
}

extension FollowersViewController: FollowersInteractorDelegate {
    func didGetFollowers(followers: [User]) {
        print("Got followers: " + String(describing: followers))
        self.followers = followers
        self.reloadViews()
        self.checkToHideEmptyState()
        self.refreshControl.endRefreshing()
    }
    
    func errorGettingFollowers() {
        print("Error getting followers")
        self.followers = []
        self.reloadViews()
        self.checkToHideEmptyState()
        self.refreshControl.endRefreshing()
    }
}
