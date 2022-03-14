//
//  PrivateProfileCell.swift
//  Exhbt
//
//  Created by Steven Worrall on 10/19/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import UIKit

class PrivateProfileCell: UITableViewCell {
    let topLabel = Label(title: "This user is private", fontSize: 20, weight: .bold)
    let bottomLabel = Label(title: "Follow to interact with them!", fontSize: 16, weight: .regular)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
            
        self.setupViews()
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        self.contentView.addSubview(self.topLabel)
        self.topLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.contentView.snp.centerX)
            make.top.equalToSuperview().offset(40)
        }
        
        self.contentView.addSubview(self.bottomLabel)
        self.bottomLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.contentView.snp.centerX)
            make.top.equalTo(self.topLabel.snp.bottom).offset(10)
            make.bottom.equalToSuperview()
        }
    }
}
