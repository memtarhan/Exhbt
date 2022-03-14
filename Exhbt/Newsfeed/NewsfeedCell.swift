//
//  NewsfeedCell.swift
//  Exhbt
//
//  Created by Steven Worrall on 6/1/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import UIKit

class NewsfeedCell: UICollectionViewCell {
    
    var competitionData: CompetitionDataModel? {
        didSet {
            if let competitionData = competitionData {
                self.addImages(comp: competitionData)
                
                self.categoryLabel.text = competitionData.category
                self.setTimerLabel(comp: competitionData)
                self.setVoteLabel()
            }
        }
    }
    
    private let imagesStack: UIStackView = {
        let temp = UIStackView()
        temp.distribution = .fillEqually
        temp.alignment = .center
        temp.axis = .horizontal
        temp.spacing = 2.0
        temp.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        temp.backgroundColor = .black
        return temp
    }()
    
    private let bottomView: UIButton = {
        let temp = UIButton()
        temp.setTitleColor(.white, for: .normal)
        temp.titleLabel?.font = UIFont(name: FontWeight.semiBold.rawValue, size: 18)
        temp.backgroundColor = .systemBlue
        temp.isUserInteractionEnabled = false
        temp.imageEdgeInsets = UIEdgeInsets(top: 0.0, left: -10.0, bottom: 0.0, right: 0.0)
        return temp
    }()
    
    private let categoryView = UIView()
    private let categoryLabel = Label(title: "", fontSize: 14, weight: .semiBold)
    
    private let timerView = UIView()
    private let timerLabel = Label(title: "", fontSize: 14, weight: .semiBold)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.imagesStack.arrangedSubviews.forEach({ $0.removeFromSuperview() })
    }
    
    private func setupViews() {
        self.backgroundColor = .clear
        self.layer.cornerRadius = 24
        self.layer.masksToBounds = true
        
        self.contentView.addSubview(self.bottomView)
        self.bottomView.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview()
            make.height.equalTo(50)
        }
        
        self.contentView.addSubview(self.imagesStack)
        self.imagesStack.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
            make.bottom.equalTo(self.bottomView.snp.top)
        }
        
        self.categoryView.backgroundColor = .white
        self.categoryView.layer.cornerRadius = 13
        self.categoryView.layer.masksToBounds = true
        self.contentView.addSubview(self.categoryView)
        self.categoryView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.bottom.equalTo(self.bottomView.snp.top).offset(-8)
            make.height.equalTo(26)
        }
        
        self.categoryView.addSubview(self.categoryLabel)
        self.categoryLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(10)
        }
        
        self.timerView.backgroundColor = .white
        self.timerView.layer.cornerRadius = 13
        self.timerView.layer.masksToBounds = true
        self.contentView.addSubview(self.timerView)
        self.timerView.snp.makeConstraints { make in
            make.leading.equalTo(self.categoryView.snp.trailing).offset(8)
            make.bottom.equalTo(self.bottomView.snp.top).offset(-8)
            make.height.equalTo(26)
        }
        
        self.timerView.addSubview(self.timerLabel)
        self.timerLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(10)
        }
    }
    
    private func addImages(comp: CompetitionDataModel) {
        for image in comp.challengeImages {
            let imageView = CustomImageView(
                imageID: image.imageID,
                sizes: [.tiny, .small]
            )
            imageView.backgroundColor = .lightGray
            
            self.imagesStack.addArrangedSubview(imageView)
        }
    }
    
    private func setVoteLabel() {
        guard let comp = self.competitionData else { return }
        
        if comp.state == .live, !comp.didUserVote() {
            self.bottomView.setTitle("See and Vote", for: .normal)
            self.bottomView.setImage(UIImage(named: "VoteThumb"), for: .normal)
            self.bottomView.backgroundColor = .systemBlue
        } else {
            self.bottomView.setTitle("👍 \(comp.getTotalVotes())", for: .normal)
            self.bottomView.setImage(nil, for: .normal)
            self.bottomView.backgroundColor = UIColor.init(named: "ExhbtGrey")
        }
    }
    
    private func setTimerLabel(comp: CompetitionDataModel) {
        switch competitionData?.state {
        case .setup:
            self.timerLabel.text = "Setup"
        case .live:
            let date = comp.getTimeRemaining() ?? ""
            let mainString = "Live · " + date
            let stringToColor = "Live"
            
            let range = (mainString as NSString).range(of: stringToColor)

            let mutableAttributedString = NSMutableAttributedString.init(string: mainString)
            mutableAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red, range: range)
            
            self.timerLabel.attributedText = mutableAttributedString
        case .expired:
            let attachment:NSTextAttachment = NSTextAttachment()
            attachment.image = UIImage(named: "FinishedIcon")

            let attachmentString = NSAttributedString(attachment: attachment)
            let myString = NSMutableAttributedString(string: "")
            myString.append(attachmentString)

            self.timerLabel.attributedText = myString
        case .none:
            self.timerLabel.text = "Error"
        }
    }
}
