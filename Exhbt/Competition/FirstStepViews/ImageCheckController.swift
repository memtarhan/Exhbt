//
//  ImageCheckController.swift
//  Exhbt
//
//  Created by Steven Worrall on 5/5/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import UIKit
import SnapKit

protocol ImageCheckerDelegate: AnyObject {
    func photoWasSelected(_ competitionImage: CompetitionImage)
}

class ImageCheckController: UIViewController {
    weak var delegate: ImageCheckerDelegate?
    
    private let competitionImage: CompetitionImage
    
    private lazy var imageView: UIImageView = {
        let temp = UIImageView()
        temp.image = self.competitionImage.image
        temp.contentMode = .scaleAspectFit
        return temp
    }()
    private lazy var createButton: Button = {
        let text = (fromInvite) ? "Join" : "Next"
        let temp = Button(title: text, fontSize: 18)
        temp.setTitleColor(UIColor.white, for: .normal)
        temp.backgroundColor = .clear
        return temp
    }()
    private let cancelButton: Button = {
        let temp = Button(title: "Cancel", fontSize: 18)
        temp.setTitleColor(UIColor.white, for: .normal)
        temp.backgroundColor = .clear
        temp.isUserInteractionEnabled = true
        return temp
    }()
    private lazy var bottomView: UIView = {
        let temp = UIView()
        temp.backgroundColor = .black
        
        temp.addSubview(self.createButton)
        self.createButton.snp.makeConstraints { (make) in
            make.width.equalTo(80)
            make.top.equalToSuperview().offset(10)
            make.trailing.bottom.equalToSuperview().offset(-10)
        }
        
        temp.addSubview(self.cancelButton)
        self.cancelButton.snp.makeConstraints { (make) in
            make.width.equalTo(80)
            make.top.leading.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        return temp
    }()
    
     private var fromInvite: Bool
    
    init(competitionImage: CompetitionImage, fromInvite: Bool) {
        self.competitionImage = competitionImage
        self.fromInvite = fromInvite

        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    func setupView() {
        self.view.backgroundColor = .black
        self.view.addSubview(self.imageView)
        
        self.imageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        self.createButton.addTarget(self, action: #selector(selectButtonPressed), for: UIControl.Event.touchUpInside)
        self.cancelButton.addTarget(self, action: #selector(cancelButtonPressed), for: UIControl.Event.touchUpInside)
        
        self.view.addSubview(self.bottomView)
        self.bottomView.snp.makeConstraints { (make) in
            make.height.equalTo(100)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    @objc private func selectButtonPressed(sender: Button) {
        let delegate = self.delegate
        self.dismiss(animated: true, completion: {
            delegate?.photoWasSelected(self.competitionImage)
        })
    }
    
    @objc private func cancelButtonPressed(sender: Button) {
        self.dismiss(animated: true, completion: nil)
    }
}
