//
//  ExploreController.swift
//  Exhbt
//
//  Created by Steven on 12/3/21.
//  Copyright © 2021 Exhbt LLC. All rights reserved.
//

import UIKit
import MessageUI

class ExploreController: UIViewController {
    
    private lazy var categories: [ChallengeCategories] = ChallengeCategories.allCases
    private var selectedCategory: ChallengeCategories = .All
    
    private var newsfeedData: [CompetitionDataModel] = []
    private var filteredData: [CompetitionDataModel] = []
    
    private let collectionCellID = "myCellID"
    private let cellHeight = 135
    private let cellWidth = 110
    
    private let collectionView: UICollectionView = {
        let tempLayout = UICollectionViewFlowLayout()
        tempLayout.scrollDirection = .horizontal
        tempLayout.minimumInteritemSpacing = 0
        tempLayout.minimumLineSpacing = 0
        let tempCollection = UICollectionView(frame: .zero, collectionViewLayout: tempLayout)
        tempCollection.contentInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        tempCollection.showsHorizontalScrollIndicator = false
        tempCollection.backgroundColor = UIColor(named: "NewsfeedSliderBackgroundColor")
        return tempCollection
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    private func filterData(by type: ChallengeCategories) {
        var tempArray: [CompetitionDataModel] = []
        
        if type == ChallengeCategories.All {
            self.filteredData = self.newsfeedData
        } else {
            self.newsfeedData.forEach { (comp) in
                if comp.category == type .rawValue {
                    tempArray.append(comp)
                }
            }
            self.filteredData = tempArray
        }
        reloadViews()
    }
    
    private func reloadViews() {
        self.collectionView.reloadData()
        
        let _ = self.filteredData[0]
    }

}

extension ExploreController: MFMailComposeViewControllerDelegate {
    func createReportEmail(competitionID: String) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["exhbtmain@gmail.com"])
            mail.setSubject("Reporting Competiton \(competitionID)")
            mail.setMessageBody("Please describe why you're reporting this competition.\n\n\n\nDo not edit below this.\nCompetiton ID: \(competitionID)", isHTML: false)

            self.present(mail, animated: true)
        } else {
            self.presentAlert(title: "Error reporting competition.", message: "Please try again soon.")
        }
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
