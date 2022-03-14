//
//  CurrentCompetitionCell.swift
//  Exhbt
//
//  Created by Shouvik Paul on 11/3/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import UIKit

class CurrentCompetitionCell: NotificationCell {
    let categoryLabel = Label(title: "", fontSize: 14)
    
    var competition: CompetitionDataModel?
    
    func set(competition: CompetitionDataModel) {
        self.competition = competition
        categoryLabel.text = competition.category
        nameLabel.text = competition.creator?.name
        avatarImageView.setImage(with: competition.creator?.avatarImageUrl ?? "")
    }
    
    override func setupView() {
        super.setupView()
        setupCategoryLabel()
    }
    
    private func setupCategoryLabel() {
        categoryLabel.textColor = .LightGray()
        contentView.addSubview(categoryLabel)
        categoryLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel)
            make.height.equalTo(18)
            make.centerY.equalTo(avatarImageView).offset(9)
        }
    }
}
