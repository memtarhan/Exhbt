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

protocol ImagePickedDelegate: AnyObject {
    func photoWasPicked(image: UIImage, fromGallery: Bool, imageUUID: String)
}

class CreateCompetitionController: UIViewController {
    private var competitionData: CompetitionDataModel
    
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
        controller.view.isHidden = true
        return controller
    }()
    
    lazy var photoPickerVC: PhotoPickerViewController = {
        let controller = PhotoPickerViewController()
        addChild(controller)
        controller.didMove(toParent: self)
        controller.view.isHidden = true
        return controller
    }()
    
    lazy var galleryVC: GalleryViewController = {
        let controller = GalleryViewController()
        addChild(controller)
        controller.didMove(toParent: self)
        controller.view.isHidden = true
        return controller
    }()
    
    private lazy var competitionInteractor: CompetitionInteractor = {
        let interactor = CompetitionInteractor()
        interactor.delegate = self
        return interactor
    }()
    
    private var fromInvite: Bool
    
    init(data: CompetitionDataModel, fromInvite: Bool = false) {
        self.competitionData = data
        self.fromInvite = fromInvite
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        
        self.navigationController!.navigationBar.topItem!.title = "Back"
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
        
        self.cameraVC.delegate = self
        self.view.addSubview(self.cameraVC.view)
        self.cameraVC.view.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(self.buttonStack.snp.top)
        }
        
        self.photoPickerVC.delegate = self
        self.view.addSubview(self.photoPickerVC.view)
        self.photoPickerVC.view.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(self.buttonStack.snp.top)
        }
        
        self.galleryVC.delegate = self
        self.view.addSubview(self.galleryVC.view)
        self.galleryVC.view.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(self.buttonStack.snp.top)
        }
        
        //set  middle to current view
        self.setCurrentView(tag: 1)
    }
    
    @objc private func segueButtonPressed(sender: UIButton!) {
        let tag = sender.tag
        if tag == CreateCompetitionController.cameraTag {
            self.setCurrentView(tag: tag)
        } else if tag == CreateCompetitionController.phoneGalTag {
            self.setCurrentView(tag: tag)
        } else if tag == CreateCompetitionController.appGalTag {
            self.setCurrentView(tag: tag)
        } else {
            return
        }
    }
    
    func setCurrentView(tag: Int) {
        self.cameraButton.setTitleColor(UIColor.black, for: .normal)
        self.phoneGalleryButton.setTitleColor(UIColor.black, for: .normal)
        self.appGalleryButton.setTitleColor(UIColor.black, for: .normal)
        self.cameraVC.view.isHidden = true
        self.photoPickerVC.view.isHidden = true
        self.galleryVC.view.isHidden = true
        
        if tag == CreateCompetitionController.cameraTag {
            self.cameraButton.setTitleColor(UIColor.lightGray, for: .normal)
            self.cameraVC.view.isHidden = false
        } else if tag == CreateCompetitionController.phoneGalTag {
            self.phoneGalleryButton.setTitleColor(UIColor.lightGray, for: .normal)
            self.photoPickerVC.view.isHidden = false
        } else if tag == CreateCompetitionController.appGalTag {
            self.appGalleryButton.setTitleColor(UIColor.lightGray, for: .normal)
            self.galleryVC.view.isHidden = false
        } else {
            return
        }
    }

    private func presentImageCheckVC(competitionImage: CompetitionImage) {
        let vc = ImageCheckController(competitionImage: competitionImage, fromInvite: fromInvite)
        vc.modalPresentationStyle = .fullScreen
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
}

extension CreateCompetitionController: ImagePickedDelegate {
    func photoWasPicked(image: UIImage, fromGallery: Bool, imageUUID: String) {
        let competitionImage = CompetitionImage(
            imageID: imageUUID,
            userID: UserManager.shared.user?.userID ?? competitionData.creatorID,
            fromGallery: fromGallery,
            image: image)
        self.presentImageCheckVC(competitionImage: competitionImage)
    }
}

extension CreateCompetitionController: ImageCheckerDelegate {
    func photoWasSelected(_ competitionImage: CompetitionImage) {
        if fromInvite {
            competitionInteractor.joinCompetition(
                competitionData,
                with: competitionImage
            )
            presentLoadingScreen()
        } else {
            competitionData.challengeImages = [competitionImage]
            let inviteVC = InviteToCompetitionViewController(data: self.competitionData)
            self.navigationController?.pushViewController(inviteVC, animated: true)
        }
    }
}

extension CreateCompetitionController: CompetitionInteractorDelegate {
    func joinedCompetition(_ competition: CompetitionDataModel) {
        removeLoadingScreen()
        
        var timeStr: String
        if let dateStr = Utilities.getReadableExpirationFrom(dateStr: competition.createdAt) {
            timeStr = "after \(dateStr)"
        } else {
            timeStr = "soon"
        }
        presentAlert(
            title: "Upload Complete!",
            message: "You have successfully joined the competition! Check back in the app \(timeStr) to check out the results!",
            completion: { _ in
                self.navigationController?.dismiss(animated: true, completion: nil)
        })
    }
    
    func errorJoiningCompeition(_ error: Error) {
        removeLoadingScreen()
        presentAlert(
            title: "Error",
            message: "Sorry we could not upload your photo at this time. Please try again.")
    }
}
