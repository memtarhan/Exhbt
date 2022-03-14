//
//  NotificationCell.swift
//  Exhbt
//
//  Created by Shouvik Paul on 11/3/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import UIKit

class NotificationCell: UITableViewCell {
    let avatarImageView = CustomImageView(sizes: [.tiny])
    let nameLabel = Label(title: "", fontSize: 16, weight: .regular)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        backgroundColor = .white
        selectionStyle = .none
        setupAvatarImage()
        setupNameLabel()
    }
    
    private func setupAvatarImage() {
        avatarImageView.layer.cornerRadius = 27
        contentView.addSubview(avatarImageView)
        avatarImageView.snp.makeConstraints { (make) in
            make.top.left.equalToSuperview()
            make.bottom.equalToSuperview().inset(14).priority(.high)
            make.height.width.equalTo(54)
        }
    }
    
    private func setupNameLabel() {
        nameLabel.minimumScaleFactor = 0.5
        nameLabel.adjustsFontSizeToFitWidth = true
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(avatarImageView.snp.right).offset(8)
            make.right.equalToSuperview().inset(100)
            make.centerY.equalTo(avatarImageView).offset(-12)
            make.height.equalTo(20)
        }
    }
}
