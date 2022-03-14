//
//  RecentSearchCell.swift
//  Exhbt
//
//  Created by Shouvik Paul on 10/26/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import UIKit

protocol RecentSearchCellDelegate: AnyObject {
    func hideRecentSearch(_ search: RecentSearch)
}

class RecentSearchCell: UITableViewCell {
    let nameLabel = Label(title: "", fontSize: 20, weight: .regular)
    let closeButton = UIButton()
    weak var delegate: RecentSearchCellDelegate?
    
    var search: RecentSearch? {
        didSet {
            if let search = search {
                nameLabel.text = search.name
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        contentView.layer.cornerRadius = 6
        backgroundColor = .white
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.left.centerY.equalToSuperview()
        }
        
        closeButton.addAction(#selector(hide), for: self)
        closeButton.setTitle("X", for: .normal)
        closeButton.setTitleColor(.black, for: .normal)
        contentView.addSubview(closeButton)
        closeButton.snp.makeConstraints { (make) in
            make.height.width.equalTo(20)
            make.right.equalToSuperview()
            make.top.bottom.equalToSuperview().inset(10)
        }
    }
    
    @objc func hide() {
        if let search = search {
            delegate?.hideRecentSearch(search)
        }
    }
}
