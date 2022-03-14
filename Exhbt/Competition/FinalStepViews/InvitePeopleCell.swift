//
//  InvitePeopleCell.swift
//  Exhbt
//
//  Created by Steven Worrall on 5/4/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import UIKit

protocol InviteCellDelegate: AnyObject {
    func challengePressed(isSelected: Bool, user: User)
}

class InvitePeopleCell: UITableViewCell {
    weak var delegate: InviteCellDelegate?
    private let buttonPadding: CGFloat = 15
    private let buttonWidth: CGFloat = 85
    
    var user: User? {
        didSet {
            guard let user = user else { return }
            guard let unwrappedString = user.name else { return }
            self.label.text = unwrappedString
            
            setButton(selected: user.selected)
            
            self.profileImage.setImage(with: user.avatarImageUrl ?? "")
        }
    }
    
    let label = Label(title: "", fontSize: 20, weight: .regular)

    let button: Button = {
        let temp = PrimaryButton(title: "challenge", fontSize: 14)
        temp.layer.shadowColor = UIColor.black.cgColor
        temp.layer.shadowRadius = 10
        temp.layer.shadowOffset = CGSize(width: 0, height: 5)
        temp.layer.shadowOpacity = 0.08
        temp.layer.masksToBounds = false
        return temp
    }()
    
    let profileImage: CustomImageView = {
        let image = CustomImageView(sizes: ImageSize.smallest(.avatar))
        image.contentMode = .scaleAspectFill
        image.layer.masksToBounds = true
        image.layer.backgroundColor = UIColor.gray.cgColor
        image.layer.cornerRadius = 22
        return image
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = .white
        
        contentView.addSubview(profileImage)
        profileImage.snp.makeConstraints { (make) in
            make.left.equalToSuperview().inset(16)
            make.width.height.equalTo(44)
            make.top.bottom.equalToSuperview().inset(8)
        }
        
        button.addTarget(self, action: #selector(challengeButtonPressed), for: .touchUpInside)
        contentView.addSubview(self.button)
        button.snp.makeConstraints { (make) in
            make.right.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.width.equalTo(self.buttonWidth)
            make.height.equalTo(24)
        }
        
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        contentView.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.leading.equalTo(profileImage.snp.trailing).offset(20)
            make.trailing.equalTo(self.button.snp.leading).offset(-4)
        }
    }
    
    @objc private func challengeButtonPressed() {
        let selected = !button.isSelected
        user?.selected = selected
        setButton(selected: selected)
        
        if let user = self.user {
            delegate?.challengePressed(isSelected: selected, user: user)
        }
    }
    
    private func setButton(selected: Bool) {
        button.isSelected = selected
        button.backgroundColor = (selected) ? .LighterGray() : .EXRed()
        let text = (button.isSelected) ? "selected" : "challenge"
        button.setTitle(text, for: .normal)
    }
}
