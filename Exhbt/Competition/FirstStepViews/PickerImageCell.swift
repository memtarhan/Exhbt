//
//  PickerImageCell.swift
//  Exhbt
//
//  Created by Steven Worrall on 5/3/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import UIKit

class PickerImageCell: UICollectionViewCell {
    public var image: UIImage? {
        didSet {
            if let unwrappedImage = self.image {
                self.customImageView.image = unwrappedImage
            }
        }
    }
    private let customImageView: UIImageView = {
        let temp = UIImageView()
        temp.contentMode = .scaleAspectFill
        temp.layer.masksToBounds = true
        return temp
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        self.backgroundColor = .lightGray
        
        self.addSubview(self.customImageView)
        self.customImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}
