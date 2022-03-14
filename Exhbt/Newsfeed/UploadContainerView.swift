//
//  UploadContainerView.swift
//  Exhbt
//
//  Created by Steven Worrall on 5/4/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import UIKit
import SnapKit

protocol UploadContainerDelegate: AnyObject {
    func hideUploadBar()
}

class UploadContainerView: UIView {
    weak var delegate: UploadContainerDelegate?
    
    private var heightConstraint: Constraint?
    private var currentUploadBarHeight: CGFloat = 70
    private let spaceForBar: CGFloat = 15
    
    private lazy var currentPercent: CGFloat = 0
    
    private lazy var uploadLabel: UILabel = {
        let temp = UILabel()
        temp.textColor = .white
        temp.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        temp.textAlignment = .center
        temp.text = "Callenge uploading."
        return temp
    }()
    private lazy var uploadBarStack: UIStackView = {
        let temp = UIStackView()
        temp.distribution = .equalCentering
        temp.alignment = .center
        temp.axis = .vertical
        temp.spacing = 10.0
        temp.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        return temp
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.backgroundColor = UIColor.init(named: "MainDarkColor")
        
        self.snp.makeConstraints { (make) in
            self.heightConstraint = make.height.equalTo(self.currentUploadBarHeight).constraint
        }
        self.addSubview(self.uploadLabel)
        self.uploadLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(30)
        }
        
        self.addSubview(self.uploadBarStack)
        self.uploadBarStack.snp.makeConstraints { (make) in
            make.top.equalTo(self.uploadLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
    }
    
    public func addUploadBar(competition: CompetitionDataModel) {
        self.updateViewHeight(isAdding: true)
        
        let tempBar = UploadBarView(competitionID: competition.competitionID)
        tempBar.delegate = self
        self.uploadBarStack.addArrangedSubview(tempBar)
        tempBar.snp.makeConstraints { (make) in
            make.height.equalTo(10)
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-30)
        }
    }
    
    public func updateBar(forCompetiton: CompetitionDataModel, percentToAdd: CGFloat) {
        guard let barArray = self.uploadBarStack.subviews as? [UploadBarView] else { return }
        
        for competition in barArray {
            if competition.competitionID == forCompetiton.competitionID {
                competition.updateWithPercent(percentChange: percentToAdd)
            }
        }
    }
    
    private func updateViewHeight(isAdding: Bool) {
        if isAdding {
            self.currentUploadBarHeight += self.spaceForBar
        } else {
            self.checkToHideUploadBar()
            self.currentUploadBarHeight -= self.spaceForBar
        }
        
        self.heightConstraint?.update(offset: self.currentUploadBarHeight)
        UIView.animate(withDuration: 0.6, animations: {
            self.layoutIfNeeded()
        })
    }
    
    private func checkToHideUploadBar() {
        if self.uploadBarStack.arrangedSubviews.count <= 0 {
            delegate?.hideUploadBar()
        }
    }
    
}

extension UploadContainerView: UploadBarDelegate {
    func finishedUploading(ID: String) {
        guard let barArray = self.uploadBarStack.subviews as? [UploadBarView] else { return }
        
        for competition in barArray {
            if competition.competitionID == ID {
                self.uploadBarStack.removeArrangedSubview(competition)
                competition.removeFromSuperview()
                self.updateViewHeight(isAdding: false)
            }
        }
    }
}
