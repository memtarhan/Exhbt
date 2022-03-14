//
//  LeaderboardController.swift
//  Exhbt
//
//  Created by Shouvik Paul on 10/13/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import UIKit
import SnapKit

class LeaderboardController: UIViewController {
    
    private let categories = ChallengeCategories.allCases
    private var selectedCategory = ChallengeCategories.All
    
    private let label: UILabel = {
        let temp = UILabel()
        temp.text = "Leaderboard"
        temp.textColor = .black
        temp.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        return temp
    }()
    private lazy var categoryCollection: UICollectionView = {
        let tempLayout = UICollectionViewFlowLayout()
        tempLayout.scrollDirection = .horizontal
        let tempCollection = UICollectionView(frame: .zero, collectionViewLayout: tempLayout)
        tempCollection.delegate = self
        tempCollection.dataSource = self
        tempCollection.register(NewsfeedCategoryCell.self, forCellWithReuseIdentifier: NSStringFromClass(NewsfeedCategoryCell.self))
        tempCollection.backgroundColor = .clear
        tempCollection.showsVerticalScrollIndicator = false
        tempCollection.showsHorizontalScrollIndicator = false
        return tempCollection
    }()
    
    private var users: [User] = []
    
    let tableViewHeader = UIView()
    let indexLabel = Label(title: "#", fontSize: 12)
    let nameLabel = Label(title: "name", fontSize: 12)
    let coinsLabel = Label(title: "coins", fontSize: 12)
    
    private lazy var leaderboardTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(LeaderboardCell.self, forCellReuseIdentifier: NSStringFromClass(LeaderboardCell.self))
        return tableView
    }()

    lazy var interactor: LeaderboardInteractor = {
        let interactor = LeaderboardInteractor()
        interactor.delegate = self
        return interactor
    }()
    
    private let searchVC = SearchController()
    private var searchShown: Bool = false
    private var searchVCShownConstraint: Constraint?
    private var searchVCHiddenConstraint: Constraint?
    
    private var seenOnce: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        categoryCollection.reloadData()
        var index = 0
        for (idx, category) in categories.enumerated() {
            if selectedCategory == category {
                index = idx
                break
            }
        }
        categoryCollection.scrollToItem(
            at: IndexPath(item: index, section: 0),
            at: .left,
            animated: false)
        if !seenOnce {
            interactor.getLeaderboard(for: selectedCategory)
            seenOnce = true
        }
    }
    
    private func setupView() {
        view.backgroundColor = .white
        setupNav()
        setupLabel()
        setupCategoryCollection()
        setupTableView()
        setupSearchController()
    }
    
    private func setupNav() {
        setNavigationTitleView()
        let searchButton = UIBarButtonItem(image: UIImage(named: "SearchIcon"), style: .plain, target: self, action: #selector(searchTap))
        
        self.navigationItem.rightBarButtonItem = searchButton
    }
    
    private func setupLabel() {
        view.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(32)
            make.left.equalToSuperview().inset(24)
        }
    }
    
    private func setupCategoryCollection() {
        view.addSubview(categoryCollection)
        categoryCollection.snp.makeConstraints { (make) in
            make.top.equalTo(label.snp.bottom).offset(16)
            make.left.right.equalToSuperview()
            make.height.equalTo(62)
        }
    }
    
    private func setupTableView() {
        setupTableViewHeader()
        view.addSubview(leaderboardTableView)
        leaderboardTableView.snp.makeConstraints { (make) in
            make.top.equalTo(tableViewHeader.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func setupTableViewHeader() {
        view.addSubview(tableViewHeader)
        tableViewHeader.snp.makeConstraints { (make) in
            make.top.equalTo(categoryCollection.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(16)
        }
        
        indexLabel.textColor = .LighterGray()
        nameLabel.textColor = .LighterGray()
        coinsLabel.textColor = .LighterGray()
        
        tableViewHeader.addSubview(indexLabel)
        indexLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview()
        }
        tableViewHeader.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().inset(48 + 54 + 16)
            make.top.bottom.equalToSuperview()
        }
        tableViewHeader.addSubview(coinsLabel)
        coinsLabel.snp.makeConstraints { (make) in
            make.left.equalTo(tableViewHeader.snp.right).offset(-54)
            make.top.bottom.equalToSuperview()
        }
    }
    
    private func setupSearchController() {
        addChild(searchVC)
        searchVC.didMove(toParent: self)
        view.addSubview(searchVC.view)
        searchVC.view.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            searchVCHiddenConstraint = make.height.equalTo(0).priority(.low).constraint
            searchVCShownConstraint = make.bottom.equalToSuperview().constraint
        }
        searchVCShownConstraint?.deactivate()
        self.searchVC.view.alpha = 0
        self.searchVC.view.isUserInteractionEnabled = false
    }
    
    @objc func searchTap() {
        searchShown = !searchShown
        if searchShown {
            searchVCHiddenConstraint?.deactivate()
            searchVCShownConstraint?.activate()
        } else {
            searchVCShownConstraint?.deactivate()
            searchVCHiddenConstraint?.activate()
        }
        
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
            if self.searchShown {
                self.searchVC.view.alpha = 1
                self.searchVC.view.isUserInteractionEnabled = true
            } else {
                self.searchVC.view.alpha = 0
                self.searchVC.view.isUserInteractionEnabled = false
            }
        }
    }
}

extension LeaderboardController: LeaderboardInteractorDelegate {
    func receivedLeaderboard(for category: ChallengeCategories, users: [User]) {
        guard category == selectedCategory else { return }

        self.users = users
        leaderboardTableView.reloadData()
    }
    
    func errorReceivingLeaderboard(_ error: Error) {
        presentAlert(title: "Error", message: "Could not fetch leaderboard for \(selectedCategory.rawValue) competitions. Please try again later.")
    }
}

extension LeaderboardController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 16
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(LeaderboardCell.self)) as? LeaderboardCell else {
            return UITableViewCell()
        }
        
        cell.selectionStyle = .none
        cell.set(user: users[indexPath.section], index: indexPath.section, category: selectedCategory)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? LeaderboardCell,
            let user = cell.user else { return }
        
        let profileVC = ProfileController(user: user)
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
}

extension LeaderboardController: UICollectionViewDelegate,
  UICollectionViewDataSource,
  UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: NSStringFromClass(NewsfeedCategoryCell.self),
            for: indexPath) as? NewsfeedCategoryCell else {
                return UICollectionViewCell ()
        }
        
        let dataForRow = self.categories[indexPath.row]
        cell.centerBlurView = true
        cell.category = dataForRow
        if cell.category == selectedCategory {
            cell.transformSelected()
            cell.selectedBorder.isHidden = false
        } else {
            cell.transformUnselected()
            cell.selectedBorder.isHidden = true
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 106, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? NewsfeedCategoryCell,
            let category = cell.category else {
                return
        }
        
        selectedCategory = category
        interactor.getLeaderboard(for: selectedCategory)
        categoryCollection.reloadData()
    }
}
