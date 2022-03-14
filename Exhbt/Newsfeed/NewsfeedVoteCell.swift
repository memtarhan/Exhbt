//
//  NewsfeedVoteCell.swift
//  Exhbt
//
//  Created by Steven Worrall on 6/11/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import UIKit
import SnapKit
import Lottie

class NewsfeedVoteCell: UICollectionViewCell {
    
    private let customImageView = CustomImageView(sizes: ImageSize.smallest(.small))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(image: CompetitionImage?) {
        if let imageID = image?.imageID {
            self.customImageView.setImage(with: imageID)
        }
    }
    
    private func setupView() {
        self.contentView.backgroundColor = .clear
        
        self.customImageView.contentMode = .scaleAspectFit
        self.customImageView.backgroundColor = .clear
        self.contentView.addSubview(customImageView)
        customImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}
