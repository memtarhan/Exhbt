//
//  NotificationInProgressCell.swift
//  Exhbt
//
//  Created by Steven Worrall on 6/15/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import UIKit

class NotificationInProgressCell: UICollectionViewCell {
    private let nameLabel: Label = {
        let temp = Label(title: "Name", fontSize: 14, weight: .regular)
        temp.textAlignment = .center
        return temp
    }()
    private let categoryLabel: Label = {
        let temp = Label(title: "Category", fontSize: 13, weight: .regular)
        temp.textAlignment = .center
        temp.textColor = .lightGray
        return temp
    }()
    public let dividerView: UIView = {
        let temp = UIView()
        temp.backgroundColor = .black
        return temp
    }()
    
    public func set(data: CompetitionDataModel, creator: User) {
        let tempImage = CustomImageView(
            imageID: creator.avatarImageUrl ?? "",
            sizes: ImageSize.smallest(.avatar)
        )
        tempImage.layer.cornerRadius = 40
        
        self.setupViews(imageView: tempImage)
        
        self.nameLabel.text = creator.name ?? "Name"
        self.categoryLabel.text = data.category
    }
    
    private func setupViews(imageView: CustomImageView) {
        self.contentView.addSubview(self.dividerView)
        self.dividerView.snp.makeConstraints { (make) in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalTo(1)
        }
        
        self.contentView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.width.height.equalTo(80)
            make.top.equalToSuperview().offset(8)
            make.centerX.equalTo(self.contentView.snp.centerX)
        }
        
        self.contentView.addSubview(self.nameLabel)
        self.nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(imageView.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(8)
        }
        
        self.contentView.addSubview(self.categoryLabel)
        self.categoryLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.nameLabel.snp.bottom).offset(4)
            make.leading.trailing.bottom.equalToSuperview().inset(8)
        }
    }
}
