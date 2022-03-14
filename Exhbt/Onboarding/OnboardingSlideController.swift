//
//  OnboardingSlideController.swift
//  Exhbt
//
//  Created by Shouvik Paul on 5/6/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import UIKit

class OnboardingSlideController: UIViewController {
    
    private let imageView: UIImageView
    private let imageSize: CGSize
    private let titleLabel: UILabel
    
    init(
        imageName: String,
        imageSize: CGSize,
        title: String
    ) {
        self.imageView = UIImageView(image: UIImage(named: imageName))
        self.imageSize = imageSize
        self.titleLabel = Label(title: title, fontSize: 18, weight: .bold)

        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    private func setupView() {
        view.backgroundColor = .white
        setupImage()
        setupTitle()
    }
    
    private func setupImage() {
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview().inset(imageSize.width)
            make.centerY.equalToSuperview().offset(-140)
        }
    }
    
    private func setupTitle() {
        titleLabel.textColor = .black
        titleLabel.numberOfLines = 0
        titleLabel.setLineHeight(23, centered: false)
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().offset(100)
            make.left.right.equalToSuperview().inset(24)
        }
    }
}
