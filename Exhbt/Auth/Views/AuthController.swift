//
//  AuthController.swift
//  Exhbt
//
//  Created by Shouvik Paul on 4/12/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import SnapKit
import FirebaseAuth

protocol AuthControllerDelegate: AnyObject {
    func authSuccess(_ user: User, for authFlow: AuthFlow)
}

protocol SignInDelegate: AnyObject {
    func signInSuccess(_ user: User, for authFlow: AuthFlow)
    func signInFailure(_ error: AuthError)
    func switchAuth(to authType: AuthType)
}

class AuthController: KeyboardController {
    static let buttonHeight = 48
    private let inset = CGFloat(24)
    
    private let containerView = UIView()
    
    private let logo = UIImageView(image: UIImage(named: "LogoWhite"))
    private let subtitleLabel = Label(title: "Capture. Compete. Win.")

    lazy var externalAuthVC: ExternalAuthController = {
        let controller = ExternalAuthController()
        controller.delegate = self
        addChild(controller)
        controller.didMove(toParent: self)
        return controller
    }()
    
    lazy var emailPassVC: EmailPassController = {
        let controller = EmailPassController()
        controller.delegate = self
        addChild(controller)
        controller.didMove(toParent: self)
        return controller
    }()
    
    weak var delegate: AuthControllerDelegate?
    
    private var externalAuthLeftConstraint: Constraint?
    private var bottomConstraint: Constraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        subscribeToKeyboardNotifications()
    
        setupView()
    }

    private func setupView() {
        view.backgroundColor = UIColor.white

        setupBackground()
        view.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            bottomConstraint = make.bottom.equalTo(view.safeAreaLayoutGuide)
                .offset(0).constraint
        }
        setupLogo()
        setupSubtitleLabel()
        setupExternalAuth()
        setupEmailPass()
    }
    
    private func setupBackground() {
        let background = UIImageView(image: UIImage(named: "LoginBackground"))
        background.contentMode = .scaleAspectFill
        view.addSubview(background)
        background.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupLogo() {
        containerView.addSubview(logo)
        logo.snp.makeConstraints { (make) in
            make.height.equalTo(57)
            make.width.equalTo(225)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-24)
        }
    }
    
    private func setupSubtitleLabel() {
        subtitleLabel.textColor = .white
        containerView.addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(logo.snp.bottom).offset(14)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setupExternalAuth() {
        containerView.addSubview(externalAuthVC.view)
        externalAuthVC.view.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().inset(inset)
            externalAuthLeftConstraint = make.left.equalToSuperview()
                .offset(inset).constraint
            make.width.equalToSuperview().inset(inset)
        }
    }
    
    private func setupEmailPass() {
        containerView.addSubview(emailPassVC.view)
        emailPassVC.view.snp.makeConstraints { (make) in
            make.bottom.equalTo(externalAuthVC.view)
            make.left.equalTo(externalAuthVC.view.snp.right)
                .offset(inset*2)
            make.width.equalTo(externalAuthVC.view)
        }
    }
    
    override func onKeyboardWillShow(keyboardSize: CGSize) {
        let keyboardOffset = containerView.heightCoveredByKeyboardOfSize(keyboardSize: keyboardSize)

        bottomConstraint?.update(offset: -keyboardOffset)
        UIView.animate(withDuration: 0.5) {
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }
    }
    
    override func onKeyboardWillHide() {
        bottomConstraint?.update(offset: 0)
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
}

extension AuthController: SignInDelegate {
    func signInSuccess(_ user: User, for authFlow: AuthFlow) {
        delegate?.authSuccess(user, for: authFlow)
    }
    
    func signInFailure(_ error: AuthError) {
        var title: String = "Error"
        var message: String
        
        switch error {
        case .wrongPassword:
            message = "Invalid password entered. Please try again."
        case .userNotFound:
            message = "Could not find user with this email."
        case .emailInUse:
            message = "This email is associated with a different login method."
        case .weakPassword:
            /// TODO: put in password rules here
            message = "Passwords must have 6 characters, one capital, one lowercase, and one number."
        case .unknown, .createError:
            title = "Oops"
            message = "We ran into some trouble. Please go back or try again."
        }
        
        presentAlert(
            title: title,
            message: message
        )
    }
    
    func switchAuth(to authType: AuthType) {
        var leftInset: CGFloat
        switch authType {
        case .external:
            leftInset = inset
        case .email:
            leftInset = -view.frame.width + inset
        }
        
        externalAuthLeftConstraint?.update(offset: leftInset)
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: [.curveEaseInOut],
            animations: {
                self.view.layoutIfNeeded()
        },
            completion: nil
        )
    }
}
