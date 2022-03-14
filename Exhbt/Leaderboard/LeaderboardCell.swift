//
//  LeaderboardCell.swift
//  Exhbt
//
//  Created by Shouvik Paul on 10/13/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import UIKit

class LeaderboardCell: UITableViewCell {
    
    let boxView = UIView()
    let numberLabel = Label(title: "", fontSize: 12, weight: .semiBold)
    let avatarImage = CustomImageView(sizes: ImageSize.smallest(.avatar))
    let nameLabel = Label(title: "", fontSize: 16, weight: .semiBold)
    let coinLabel = Label(title: "", fontSize: 16, weight: .semiBold)
    
    var user: User?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(user: User, index: Int, category: ChallengeCategories) {
        self.user = user
        nameLabel.text = user.name
        avatarImage.setImage(with: user.avatarImageUrl ?? "")
        numberLabel.text = "\(index + 1)"
        coinLabel.text = "\(getUserCoins(for: category, user: user))"
        
        boxView.layer.borderWidth = (index == 0) ? 1 : 0
        let isSelf = UserManager.shared.user?.userID == user.userID
        boxView.backgroundColor = (isSelf) ? .EXRed() : .clear
    }
    
    private func setupView() {
        contentView.backgroundColor = .white
        boxView.backgroundColor = .clear
        boxView.layer.cornerRadius = 4
        boxView.layer.borderColor = UIColor.EXRed().cgColor
        contentView.addSubview(boxView)
        boxView.snp.makeConstraints { (make) in
            make.left.right.centerY.equalToSuperview()
            make.height.equalTo(42)
        }
        contentView.addSubview(numberLabel)
        numberLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
        
        avatarImage.layer.cornerRadius = 27
        contentView.addSubview(avatarImage)
        avatarImage.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.width.height.equalTo(54)
            make.left.equalToSuperview().inset(48)
        }
        
        contentView.addSubview(coinLabel)
        coinLabel.snp.makeConstraints { (make) in
            make.left.equalTo(contentView.snp.right).offset(-54)
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.numberOfLines = 1
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(avatarImage.snp.right).offset(16)
            make.centerY.equalToSuperview()
            make.right.equalTo(coinLabel.snp.left).offset(-4)
        }
    }
    
    private func getUserCoins(for category: ChallengeCategories, user: User) -> Int {
        switch category {
        case .All:
            return user.coins
        case .Architecture:
            return user.architectureCoins
        case .Food:
            return user.foodCoins
        case .Art:
            return user.artCoins
        case .Nature:
            return user.natureCoins
        case .Sports:
            return user.sportsCoins
        case .Beauty:
            return user.beautyCoins
        case .Fitness:
            return user.fitnessCoins
        case .Auto:
            return user.autoCoins
        case .Fashion:
            return user.fashionCoins
        case .Animals:
            return user.animalsCoins
        }
    }
}

