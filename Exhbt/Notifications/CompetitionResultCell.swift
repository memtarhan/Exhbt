//
//  CompetitionResultCell.swift
//  Exhbt
//
//  Created by Shouvik Paul on 11/3/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import UIKit

class CompetitionResultCell: CurrentCompetitionCell {
    let coinLabel = Label(title: "", fontSize: 14, weight: .regular)
    
    let coinImageView: UIImageView = {
        let temp = UIImageView(image: UIImage(named: "CoinYellow"))
        temp.contentMode = .scaleAspectFill
        temp.layer.masksToBounds = true
        return temp
    }()
    
    func set(result: CompetitionResultNotification) {
        super.set(competition: result.competition)
        
        coinLabel.text = "\(result.notification.coins ?? 0)"
    }
    
    override func setupView() {
        super.setupView()
        setupCoinView()
    }
    
    private func setupCoinView() {
        contentView.addSubview(coinImageView)
        coinImageView.snp.makeConstraints { (make) in
            make.right.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
        
        contentView.addSubview(coinLabel)
        coinLabel.snp.makeConstraints { (make) in
            make.right.equalTo(coinImageView.snp.left).offset(-2)
            make.centerY.equalToSuperview()
        }
    }
}
