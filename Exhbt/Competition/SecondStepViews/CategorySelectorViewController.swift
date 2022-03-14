//
//  CategorySelectorViewController.swift
//  Exhbt
//
//  Created by Steven Worrall on 5/3/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import UIKit
import FirebaseCrashlytics

class CategorySelectorViewController: UIViewController {
    let userManager = UserManager.shared
    
    private lazy var categories: [ChallengeCategories] = {
        var all = ChallengeCategories.allCases
        all.remove(at: 0)
        return all
    }()
    private let cellID = "categoryCellID"
    private lazy var cellExpandedHeight = self.cellHeight * 1.5
    
    private lazy var cellHeight = UIScreen.main.bounds.width * 0.45
    private lazy var cellWidth = self.cellHeight * 0.8
    
    private var centerCell: NewsfeedCategoryCell?
    
    private lazy var collectonView: UICollectionView = {
        let tempLayout = SnappingLayout()
        let tempCollection = UICollectionView(frame: .zero, collectionViewLayout: tempLayout)
        tempCollection.backgroundColor = .clear
        tempCollection.showsVerticalScrollIndicator = false
        tempCollection.showsHorizontalScrollIndicator = false
        return tempCollection
    }()
    private let label: UILabel = {
        let temp = UILabel()
        temp.text = "Choose a Category"
        temp.textColor = .black
        temp.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        temp.textAlignment = .center
        return temp
    }()
    private lazy var nextButton: Button = {
        let temp = Button(title: "Next", fontSize: 14)
        
        temp.setTitleColor(UIColor.white, for: .normal)
        temp.layer.backgroundColor = UIColor.EXRed().cgColor
        temp.addTarget(self, action: #selector(self.onNextTapped), for: .touchUpInside)
        
        return temp
    }()
        
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationTitleView()
        self.setupViews()
        self.setupCollectionView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.setCellSelected(indexPath: IndexPath(row: 0, section: 0))
    }

    private func setupViews() {
        self.view.backgroundColor = .white
        
        self.view.addSubview(self.label)
        self.label.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.snp.top).offset(80)
            make.leading.trailing.equalToSuperview()
        }
        
        self.view.addSubview(self.nextButton)
        self.nextButton.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().inset(20)
            make.height.equalTo(UIScreen.main.bounds.width * 0.13)
        }
    }
    
    @objc private func onNextTapped(sender: UIBarButtonItem) {
        guard let category = self.centerCell?.category,
            let userID = UserManager.shared.user?.userID else {
            self.presentAlert(title: "", message: "You must select a category first.")
            return
        }
        
        let competion = CompetitionDataModel(
            competitionID: UUID().uuidString,
            creatorID: userID,
            category: category.rawValue)
        
        let cameraVC = CreateCompetitionController(data: competion)
        self.navigationController?.pushViewController(cameraVC, animated: true)
    }
}

extension CategorySelectorViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private func setupCollectionView() {
        self.collectonView.delegate = self
        self.collectonView.dataSource = self
        
        self.collectonView.register(NewsfeedCategoryCell.self, forCellWithReuseIdentifier: self.cellID)
        
        self.view.addSubview(self.collectonView)
        self.collectonView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(self.cellExpandedHeight + 10)
        }
        
        self.addCategorySelectorOffset()
    }
    
    private func addCategorySelectorOffset() {
        let sideInset = (self.view.frame.width / 2) - (self.cellWidth / 2)
        
        self.collectonView.contentInset = UIEdgeInsets(top: 0, left: sideInset, bottom: 0, right: sideInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let dataForRow = self.categories[indexPath.row]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellID, for: indexPath) as! NewsfeedCategoryCell
        
        cell.category = dataForRow
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.cellWidth, height: self.cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.collectonView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView is UICollectionView else { return }
        
        let centerPoint = CGPoint(x: self.collectonView.frame.width / 2 + scrollView.contentOffset.x,
                                  y: self.collectonView.frame.height / 2 + scrollView.contentOffset.y)
        
        if let indexPath = self.collectonView.indexPathForItem(at: centerPoint), self.centerCell == nil {
            self.setCellSelected(indexPath: indexPath)
        }
        
        if let cell = self.centerCell {
            let offsetX = centerPoint.x - cell.center.x
            
            if offsetX < -(self.cellWidth / 2) || offsetX > (self.cellWidth / 2) {
                cell.transformUnselected()
                self.centerCell = nil
            }
        }
        
    }
    
    private func setCellSelected(indexPath: IndexPath) {
        self.centerCell = self.collectonView.cellForItem(at: indexPath) as? NewsfeedCategoryCell
        
        self.centerCell?.transformSelected()
        
        for cell in self.collectonView.visibleCells as! [NewsfeedCategoryCell] {
            cell.selectedBorder.isHidden = true
        }
        self.centerCell?.selectedBorder.isHidden = false
    }
}
