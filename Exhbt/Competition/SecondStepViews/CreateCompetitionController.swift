//
//  CreateCompetitionController.swift
//  Exhbt
//
//  Created by Steven Worrall on 4/8/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import UIKit
import SnapKit
import Photos

protocol ImagePickedDelegate: class {
    func photoWasPicked(image: UIImage)
}

class CreateCompetitionController: UIViewController {
    private lazy var competitionData = CompetitionDataModel()
    private static let cameraTag = 1
    private static let phoneGalTag = 0
    private static let appGalTag = 2
    
    private lazy var cameraButton: UIButton = {
        let temp = UIButton()
        temp.setTitle("Photo", for: .normal)
        temp.backgroundColor = UIColor.clear
        temp.setTitleColor(UIColor.lightGray, for: .normal)
        temp.titleLabel?.font = .systemFont(ofSize: 20)
        temp.tag = CreateCompetitionController.cameraTag
        return temp
    }()
    
    private var phoneGalleryButton: UIButton = {
        let temp = UIButton()
        temp.setTitle("Library", for: .normal)
        temp.backgroundColor = UIColor.clear
        temp.setTitleColor(UIColor.black, for: .normal)
        temp.titleLabel?.font = .systemFont(ofSize: 20)
        temp.tag = CreateCompetitionController.phoneGalTag
        return temp
    }()
    
    private var appGalleryButton: UIButton = {
        let temp = UIButton()
        temp.setTitle("Gallery", for: .normal)
        temp.backgroundColor = UIColor.clear
        temp.setTitleColor(UIColor.black, for: .normal)
        temp.titleLabel?.font = .systemFont(ofSize: 20)
        temp.tag = CreateCompetitionController.appGalTag
        return temp
    }()
    
    private lazy var buttonStack: UIStackView = {
        let temp = UIStackView()
        temp.distribution = .fillEqually
        temp.alignment = .center
        temp.axis = .horizontal
        return temp
    }()
    
    lazy var cameraVC: CameraViewController = {
        let controller = CameraViewController()
        addChild(controller)
        controller.didMove(toParent: self)
        return controller
    }()
    
//    private lazy var cameraView: CameraView = {
//        let temp = CameraView()
//
//        return temp
//    }()
//
//    private lazy var photoPickerView: PhotoPickerView = {
//        let temp = PhotoPickerView()
//
//        return temp
//    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        
        self.navigationItem.title = "EXHBT"
    }
    
    private func setupView() {
        self.view.backgroundColor = .white

        self.cameraButton.addTarget(self, action: #selector(segueButtonPressed), for: UIControl.Event.touchUpInside)
        self.phoneGalleryButton.addTarget(self, action: #selector(segueButtonPressed), for: UIControl.Event.touchUpInside)
        self.appGalleryButton.addTarget(self, action: #selector(segueButtonPressed), for: UIControl.Event.touchUpInside)
        
        self.buttonStack.addArrangedSubview(self.phoneGalleryButton)
        self.buttonStack.addArrangedSubview(self.cameraButton)
        self.buttonStack.addArrangedSubview(self.appGalleryButton)
        
        self.view.addSubview(self.buttonStack)
        self.buttonStack.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.view.snp.bottom)
            make.leading.equalTo(self.view.snp.leading)
            make.trailing.equalTo(self.view.snp.trailing)
            make.height.equalTo(80)
        }
        
        self.view.addSubview(cameraVC.view)
        cameraVC.view.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(self.buttonStack.snp.top)//.offset(200)
        }
    }
    
    @objc private func segueButtonPressed(sender: UIButton!) {
        let tag = sender.tag
        if tag == CreateCompetitionController.cameraTag {
            print("camera tapped")
            self.setButtonColor(tag: tag)
        } else if tag == CreateCompetitionController.phoneGalTag {
            print("phone gallery tapped")
            self.setButtonColor(tag: tag)
        } else if tag == CreateCompetitionController.appGalTag {
            print("app gallery tapped")
            self.setButtonColor(tag: tag)
        } else {
            return
        }
    }
    
    func setButtonColor(tag: Int) {
        self.cameraButton.setTitleColor(UIColor.black, for: .normal)
        self.phoneGalleryButton.setTitleColor(UIColor.black, for: .normal)
        self.appGalleryButton.setTitleColor(UIColor.black, for: .normal)
        
        if tag == CreateCompetitionController.cameraTag {
            self.cameraButton.setTitleColor(UIColor.lightGray, for: .normal)
        } else if tag == CreateCompetitionController.phoneGalTag {
            self.phoneGalleryButton.setTitleColor(UIColor.lightGray, for: .normal)
        } else if tag == CreateCompetitionController.appGalTag {
            self.appGalleryButton.setTitleColor(UIColor.lightGray, for: .normal)
        } else {
            return
        }
    }
}

extension CreateCompetitionController: ImagePickedDelegate {
    func photoWasPicked(image: UIImage) {
        competitionData.image = image
        let vc = 
    }
}
