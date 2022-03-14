//
//  CategoryCell.swift
//  Exhbt
//
//  Created by Steven Worrall on 5/3/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import UIKit

class CategoryCell: UICollectionViewCell {
    var category: String? {
        didSet {
            guard let unwrappedString = category else { return }
            self.label.text = unwrappedString
            
            let imageName = unwrappedString + "Category"
            if let temp = UIImage(named: imageName) {
                self.imageView.image = temp
            }
        }
    }
    private let imageView: UIImageView = {
        let temp = UIImageView()
        temp.contentMode = .scaleAspectFill
        temp.layer.masksToBounds = true
        return temp
    }()
   private let label: UILabel = {
        let temp = UILabel()
        temp.textColor = .white
        temp.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        temp.textAlignment = .center
        return temp
    }()
    private let overlayView: UIView = {
        let temp = UIView()
        temp.backgroundColor = .black
        return temp
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        self.backgroundColor = .lightGray
        
        self.addSubview(self.imageView)
        self.imageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        self.addSubview(self.overlayView)
        self.changeOverlay(isActive: true)
        self.overlayView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        self.addSubview(self.label)
        self.label.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
//        layer.shadowColor = UIColor.black.cgColor
//        layer.shadowRadius = 20
//        layer.shadowOffset = CGSize(width: 0, height: 10)
//        layer.shadowOpacity = 0.08
//        layer.masksToBounds = false
        
    }
    
    public func changeOverlay(isActive: Bool) {
        if isActive {
            self.overlayView.layer.opacity = 0.6
        } else {
            self.overlayView.layer.opacity = 0.0
        }
    }
}
