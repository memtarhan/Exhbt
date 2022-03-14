//
//  EditProfileController.swift
//  Exhbt
//
//  Created by Steven Worrall on 6/4/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import SnapKit

class EditProfileController: KeyboardController {
    
    private let scrollView = UIScrollView()
    private let containerView = UIView()
    private var scrollViewBottom: Constraint?
    
    lazy var imagePicker = UIImagePickerController()
    private var avatarUpdated: Bool = false
    private var avatarUploadError: Bool = false

    private let customImageView: CustomImageView = {
        let temp = CustomImageView(sizes: [])
        temp.backgroundColor = .black
        return temp
    }()
    private lazy var changePhotoButton: UIButton = {
        let temp = UIButton()
        temp.addTarget(
            self,
            action: #selector(self.selectPhotoPressed(_:)),
            for: .touchUpInside)
        temp.setTitle("Change Photo", for: .normal)
        temp.titleLabel?.font = UIFont(name: "Helvetica Neue", size: 20)
        temp.setTitleColor(UIColor(named: "GoldButtonColor"), for: .normal)
        temp.backgroundColor = .clear
        return temp
    }()
    private let nameLabel: UILabel = {
        let temp = UILabel()
        temp.text = "Name"
        temp.textColor = .lightGray
        temp.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        temp.textAlignment = .center
        return temp
    }()
    private lazy var nameInput: UITextField = {
        let temp = TextField(text: user.name, placeholder: "Your username")
        temp.delegate = self
        temp.autocapitalizationType = .words
        temp.returnKeyType = .done
        return temp
    }()
    private let bioLabel: UILabel = {
        let temp = UILabel()
        temp.text = "Bio"
        temp.textColor = .lightGray
        temp.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        temp.textAlignment = .center
        return temp
    }()
    private lazy var bioInput: UITextField = {
        let temp = TextField(text: user.bio, placeholder: "Your bio.")
        temp.delegate = self
        temp.returnKeyType = .done
        return temp
    }()
    
    lazy var userInteractor: ProfileInteractor = {
        let interactor = ProfileInteractor()
        interactor.delegate = self
        return interactor
    }()
    
    private var user: User
    
    var needsToCompleteProfile: Bool {
        return navigationController?.viewControllers.count == 1
    }
    
    init(user: User) {
        self.user = user
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        subscribeToKeyboardNotifications()

        self.setupView()
        self.setupSubviews()
        self.setImage()
    }
    
    override func onKeyboardWillShow(keyboardSize: CGSize) {
        let keyboardOffset = scrollView.heightCoveredByKeyboardOfSize(keyboardSize: keyboardSize)

        scrollViewBottom?.update(offset: -keyboardOffset - 10)
        UIView.animate(withDuration: 0.5) {
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }
    }
    
    override func onKeyboardWillHide() {
        scrollViewBottom?.update(offset: 0)
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }

    private func setImage() {
        self.customImageView.setImage(with: user.avatarImageUrl ?? "")
    }
    
    private func setupView() {
        self.view.backgroundColor = .white
        
        setNavigationTitleView()
        let saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveTap))
        navigationItem.rightBarButtonItem = saveButton
        
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide)
            scrollViewBottom = make.bottom.equalToSuperview().constraint
            make.left.right.equalToSuperview()
        }
        scrollView.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.width.equalTo(view)
        }
    }
    
    private func setupSubviews() {
        self.containerView.addSubview(self.customImageView)
        self.customImageView.snp.makeConstraints { (make) in
            make.leading.top.trailing.equalToSuperview()
            make.height.equalTo(TopProfileCell.imageHeight)
        }
        
        self.containerView.addSubview(self.changePhotoButton)
        self.changePhotoButton.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(self.customImageView.snp.bottom).offset(30)
        }
        
        self.containerView.addSubview(self.nameLabel)
        self.nameLabel.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(self.changePhotoButton.snp.bottom).offset(50)
        }
        
        self.containerView.addSubview(self.nameInput)
        self.nameInput.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview().inset(48)
            make.top.equalTo(self.nameLabel.snp.bottom).offset(10)
        }
        
        self.containerView.addSubview(self.bioLabel)
        self.bioLabel.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(nameInput.snp.bottom).offset(48)
        }
        
        self.containerView.addSubview(self.bioInput)
        self.bioInput.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview().inset(48)
            make.top.equalTo(self.bioLabel.snp.bottom).offset(10)
            make.bottom.equalToSuperview().inset(16)
        }
    }
    
    @objc func saveTap() {
        presentLoadingScreen()
        avatarUploadError = false
        if avatarUpdated, let image = customImageView.image {
            userInteractor.uploadAvatarImage(image)
        } else {
            updateUser()
        }
    }
    
    private func updateUser() {
        if let text = nameInput.text, text.count > 0 {
            user.name = text
        }
        if let text = bioInput.text, text.count > 0 {
            user.bio = text
        }
        userInteractor.updateUser(user)
    }
}

extension EditProfileController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @objc func selectPhotoPressed(_ sender: Any) {
        print("select photo")
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = false

            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var completion: (() -> Void)?
        if let image = info[.originalImage] as? UIImage {
            completion = {
                let cropVC = CropImageViewController(image: image)
                cropVC.delegate = self
                cropVC.modalPresentationStyle = .fullScreen
                self.present(cropVC, animated: true, completion: nil)
            }
        }
        dismiss(animated: true, completion: completion)
    }
}

extension EditProfileController: CropImageViewControllerDelegate {
    func didCropImage(_ image: UIImage) {
        customImageView.image = image
        avatarUpdated = true
    }
}

extension EditProfileController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension EditProfileController: ProfileInteractorDelegate {
    func didRecieveUser(user: User) {
        return
    }
    
    func didRecieveFollowersData(followers: Int) {
        return
    }
    
    func didRecieveRequestData(didRequest: Bool) {
        return
    }
    
    func updateSuccess(_ user: User) {
        removeLoadingScreen()
        print("update user success: \(user)")
        
        if needsToCompleteProfile {
            navigationController?.dismiss(animated: true, completion: nil)
            return
        }
        
        if avatarUploadError {
            presentAlert(
                title: "Failed to upload avatar",
                message: "Rest of user update was successful"
            )
        }
        navigationController?.popViewController(animated: true)
    }
    
    func updateFailure(_ error: Error) {
        removeLoadingScreen()
        presentAlert(
            title: "Error",
            message: "Could not update profile at this time. Please try again."
        )
    }
    
    func uploadedAvaterImage(with ID: String) {
        avatarUpdated = false
        user.avatarImageUrl = ID
        updateUser()
    }
    
    func failedToUploadAvatarImage(_ error: Error) {
        avatarUpdated = false
        avatarUploadError = true
        updateUser()
    }
}
