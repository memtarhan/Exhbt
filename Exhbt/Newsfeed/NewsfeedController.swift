//
//  ViewController.swift
//  Exhbt
//
//  Created by Steven Worrall on 4/8/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import UIKit
import SnapKit
import MessageUI

class NewsfeedController: UIViewController {
    private var newsfeedData: [CompetitionDataModel] = []
    
    private var uploadContainerTopConstraint: Constraint?
    private var newsfeedInteractor = NewsfeedInteractor()
    
    private let collectionCellID = "myCellID"
    private lazy var cellSize = CGSize(width: self.view.bounds.width - 20, height: self.view.bounds.height / 2.5)
    
    private let refreshControl = UIRefreshControl()
    
    private lazy var collectionView: UICollectionView = {
        let tempLayout = UICollectionViewFlowLayout()
        tempLayout.scrollDirection = .vertical
        tempLayout.minimumInteritemSpacing = 0
        tempLayout.minimumLineSpacing = 10
        let tempCollection = UICollectionView(frame: .zero, collectionViewLayout: tempLayout)
        tempCollection.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        tempCollection.showsHorizontalScrollIndicator = false
        tempCollection.backgroundColor = UIColor(named: "NewsfeedSliderBackgroundColor")
        tempCollection.refreshControl = self.refreshControl
        return tempCollection
    }()
    
    private let emptyState = CompetitionEmptyState()
    
    private var noMoreComps: Bool = false
    private var newData: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupNewsfeedInteractorDelegate()
        self.reloadData()
        self.setNavigationTitleView()
        self.setupView()
        self.setupCollectionView()
        self.addEmptyState()
    }

    private func setupView() {
        self.view.backgroundColor = .white
        
        self.refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
    }
    
    private func addEmptyState() {
        self.emptyState.isHidden = false
        
        self.view.addSubview(self.emptyState)
        self.emptyState.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func toggleEmptyState(dataCount: Int) {
        print("datacount: \(dataCount)")
        if dataCount > 0 {
            self.emptyState.isHidden = true
        } else {
            self.emptyState.isHidden = false
        }
    }
    
    private func reloadViews() {
        self.collectionView.reloadData()
    }
    
    @objc func didPullToRefresh() {
        self.reloadData()
    }
}

extension NewsfeedController: NewsfeedVoteControllerDelegate {
    func didVote(comp: CompetitionDataModel?) {
        self.reloadViews()
    }
}

extension NewsfeedController: NewsfeedInteractorDelegate {
    private func setupNewsfeedInteractorDelegate() {
        self.newsfeedInteractor.delegate = self
    }
    
    private func reloadData() {
        self.newData = true
        
        self.refreshControl.beginRefreshing()
        self.newsfeedInteractor.getCompetitions(refresh: true)
    }
    
    func didReceiveCompetitions(competitions: [CompetitionDataModel]) {
        guard competitions.count > 0 else {
            noMoreComps = true
            return
        }
        
        if self.newData {
            self.newsfeedData = competitions
        } else {
            self.newsfeedData += competitions
        }
        
        self.reloadViews()
        self.refreshControl.endRefreshing()
        self.toggleEmptyState(dataCount: self.newsfeedData.count)
        
        self.newData = false
    }
    
    func errorReceivingCompetitions(error: CompetitionError) {
        self.toggleEmptyState(dataCount: 0)
    }
}

extension NewsfeedController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private func setupCollectionView() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.collectionView.register(NewsfeedCell.self, forCellWithReuseIdentifier: self.collectionCellID)
        
        self.view.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.newsfeedData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.collectionCellID, for: indexPath) as! NewsfeedCell
        
        let competition = self.newsfeedData[indexPath.row]
        
        cell.competitionData = competition
        
        if !noMoreComps, indexPath.row + 5 >= newsfeedData.count {
            newsfeedInteractor.getCompetitions()
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selected = self.newsfeedData[indexPath.row]
        
        let vc = NewsfeedVoteController(competition: selected)
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
