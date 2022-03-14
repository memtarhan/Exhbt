//
//  ExternalAuthController.swift
//  Exhbt
//
//  Created by Shouvik Paul on 4/12/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import Foundation
import FirebaseAuth
import AuthenticationServices
import CryptoKit
import FBSDKLoginKit

class ExternalAuthController: UIViewController {
    
    private var currentAppleNonce: String?
    private var signupType: AuthProvider = .email
    
    lazy var appleButton = createAppleButton()
    lazy var facebookButton = createFacebookButton()
    lazy var emailButton = createEmailButton()
    
    private let stackView = UIStackView()
    
    lazy var authInteractor: AuthInteractor = {
        let interactor = AuthInteractor()
        interactor.delegate = self
        return interactor
    }()
    
    weak var delegate: SignInDelegate?
    
    init() {
        
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
        view.addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 12
        
        stackView.addArrangedSubview(appleButton)
        stackView.addArrangedSubview(facebookButton)
        stackView.addArrangedSubview(emailButton)
    }
    
    private func createAppleButton() -> UIControl {
        let button = ASAuthorizationAppleIDButton()
        button.addTarget(self, action: #selector(appleButtonTap), for: .touchUpInside)
        button.snp.makeConstraints { (make) in
            make.height.equalTo(AuthController.buttonHeight)
        }
        return button
    }
    
    private func createFacebookButton() -> UIButton {
        let button = UIButton()
        let buttonView = createButtonView(text: "Login with Facebook", imageName: "FacebookIcon")
        button.addSubview(buttonView)
        buttonView.snp.makeConstraints { (make) in
            make.top.bottom.centerX.equalToSuperview()
        }
        button.backgroundColor = .FacebookBlue()
        button.addTarget(self, action: #selector(facebookButtonTap), for: .touchUpInside)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.snp.makeConstraints { (make) in
            make.height.equalTo(AuthController.buttonHeight)
        }
        return button
    }
    
    private func createEmailButton() -> UIButton {
        let button = UIButton()
        let buttonView = createButtonView(text: "Login with Email", imageName: "EmailIcon")
        button.addSubview(buttonView)
        buttonView.snp.makeConstraints { (make) in
            make.top.bottom.centerX.equalToSuperview()
        }
        button.backgroundColor = .DarkGray()
        button.addTarget(self, action: #selector(emailButtonTap), for: .touchUpInside)
        button.snp.makeConstraints { (make) in
            make.height.equalTo(AuthController.buttonHeight)
        }
        return button
    }

    private func createButtonView(text: String, imageName: String) -> UIView {
        let buttonView = UIView()
        let imageView = UIImageView(image: UIImage(named: imageName))
        let label = Label(title: text, fontSize: 17)
        label.textColor = .white

        buttonView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.left.centerY.equalToSuperview()
            make.width.equalTo(20)
            make.height.equalTo(imageName == "EmailIcon" ? 15 : 20)
        }
        buttonView.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.left.equalTo(imageView.snp.right).offset(8)
            make.right.centerY.equalToSuperview()
        }
        buttonView.isUserInteractionEnabled = false
        return buttonView
    }
    
    internal func showEULA() {
        let termsController = TermsController()
        termsController.delegate = self
        self.present(termsController, animated: true, completion: nil)
    }

    @objc func appleAction() {
        let nonce = randomNonceString()
        currentAppleNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    @objc func appleButtonTap() {
        self.signupType = .apple
        self.showEULA()
    }
    
    private func facebookActon() {
        let manager = LoginManager()
        manager.logIn(
            permissions: ["public_profile", "email"],
            from: self,
            handler: facebookLoginHandler()
        )
    }
    
    @objc func facebookButtonTap() {
        self.signupType = .facebook
        self.showEULA()
    }
    
    @objc func emailButtonTap() {
        self.signupType = .email
        delegate?.switchAuth(to: .email)
    }
    
    private func facebookLoginHandler() -> LoginManagerLoginResultBlock {
        return { (result: LoginManagerLoginResult?, error: Error?) -> Void in
            if let error = error {
                print("FB login error: \(error.localizedDescription)")
            }
            guard let tokenString = AccessToken.current?.tokenString else {
                self.presentAlert(
                    title: "Oops!",
                    message: "We ran into some trouble. Please go back or try again."
                )
                return
            }

            let credential = FacebookAuthProvider.credential(withAccessToken: tokenString)
            self.signIn(for: .facebook, with: credential)
        }
    }
    
    private func signIn(
        for provider: AuthProvider,
        with credential: AuthCredential
    ) {
        authInteractor.externalSignIn(for: provider, with: credential)
    }
}

extension ExternalAuthController: AuthInteractorDelegate {
    func signInSuccess(_ user: User, for authFlow: AuthFlow) {
        delegate?.signInSuccess(user, for: authFlow)
    }

    func signInError(_ error: AuthError) {
        delegate?.signInFailure(error)
    }
}

extension ExternalAuthController: TermsControllerDelegate {
    func acceptedEULA() {
        switch self.signupType {
        case .apple:
            self.appleAction()
        case .email:
            self.emailButtonTap()
        case .facebook:
            self.facebookActon()
        }
    }
}

// apple login
extension ExternalAuthController: ASAuthorizationControllerDelegate,
ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization) {
        
        guard let nonce = currentAppleNonce,
            let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
            let identityToken = appleIDCredential.identityToken,
            let idTokenString = String(data: identityToken, encoding: .utf8) else {
                
                return
        }
    
        let credential = OAuthProvider.credential(
            withProviderID: "apple.com",
            idToken: idTokenString,
            rawNonce: nonce)

        signIn(for: .apple, with: credential)
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        presentAlert(
            title: "Oops!",
            message: "We ran into some trouble. Please go back or try again."
        )
    }

    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}
