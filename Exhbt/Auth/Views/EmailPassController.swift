//
//  EmailPassController.swift
//  Exhbt
//
//  Created by Shouvik Paul on 5/3/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import SnapKit


class EmailPassController: UIViewController {
    
    lazy var authInteractor: AuthInteractor = {
        let interactor = AuthInteractor()
        interactor.delegate = self
        return interactor
    }()
    
    private lazy var backButton: UIButton = {
        let button = Button(title: "Back", fontSize: 14)
        button.setTitleColor(.darkGray, for: .normal)
        button.addTarget(self, action: #selector(backTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var emailField: UITextField = {
        let field = TextField(placeholder: "Email")
        field.delegate = self
        return field
    }()
    
    private lazy var passwordField: UITextField = {
        let field = TextField(placeholder: "Password")
        field.delegate = self
        return field
    }()
    
    private lazy var createButton: UIButton = {
        let button = PrimaryButton(title: "Sign up", fontSize: 17)
        button.addTarget(self, action: #selector(createTap), for: .touchUpInside)
        return button
    }()
    
    private let spacer = UIView()
    
    private lazy var loginButton: UIButton = {
        let button = PrimaryButton(title: "Login", fontSize: 17)
        button.addTarget(self, action: #selector(loginTap), for: .touchUpInside)
        return button
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
        setupBackButton()
        setupEmailField()
        setupPasswordField()
        setupButtonSpacer()
        setupCreateButton()
        setupLoginButton()
    }
    
    private func setupBackButton() {
        view.addSubview(backButton)
        backButton.snp.makeConstraints { (make) in
            make.top.left.equalToSuperview()
        }
    }
    
    
    private func setupEmailField() {
        emailField.keyboardType = .emailAddress
        emailField.returnKeyType = .next
        emailField.autocapitalizationType = .none
        view.addSubview(emailField)
        emailField.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(backButton.snp.bottom).offset(12)
        }
    }
    
    private func setupPasswordField() {
        passwordField.keyboardType = .asciiCapable
        passwordField.isSecureTextEntry = true
        passwordField.returnKeyType = .done
        view.addSubview(passwordField)
        passwordField.snp.makeConstraints { (make) in
            make.top.equalTo(emailField.snp.bottom).offset(16)
            make.left.right.equalToSuperview()
        }
    }
    
    private func setupButtonSpacer() {
        view.addSubview(spacer)
        spacer.snp.makeConstraints { (make) in
            make.top.equalTo(passwordField.snp.bottom).offset(32)
            make.height.equalTo(16)
            make.bottom.centerX
                .equalToSuperview()
            make.width.equalTo(100)
        }
    }
    
    private func setupCreateButton() {
        view.addSubview(createButton)
        createButton.snp.makeConstraints { (make) in
            make.right.equalTo(spacer.snp.left)
            make.centerY.equalTo(spacer)
            make.width.equalTo(100)
        }
    }
    
    private func setupLoginButton() {
        view.addSubview(loginButton)
        loginButton.snp.makeConstraints { (make) in
            make.left.equalTo(spacer.snp.right)
            make.centerY.equalTo(spacer)
            make.width.equalTo(100)
        }
    }
    
    @objc func backTap() {
        self.view.endEditing(true)
        delegate?.switchAuth(to: .external)
    }
    
    @objc func createTap() {
        let termsController = TermsController()
        termsController.delegate = self
        self.present(termsController, animated: true, completion: nil)
    }
    
    @objc func loginTap() {
        signIn(for: .login)
    }
    
    private func signIn(for flow: AuthFlow) {
        guard let email = emailField.text,
            let password = passwordField.text,
            !email.isEmpty, !password.isEmpty
            else {
                presentAlert(
                    title: "Error",
                    message: "Please fill out email and password fields."
                )
                return
        }
        
        presentLoadingScreen()
        
        authInteractor.internalSignIn(
            email: email,
            password: password,
            authFlow: flow
        )
    }
}

extension EmailPassController: TermsControllerDelegate {
    func acceptedEULA() {
        signIn(for: .signup)
    }
}

extension EmailPassController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}

extension EmailPassController: AuthInteractorDelegate {
    func signInSuccess(_ user: User, for authFlow: AuthFlow) {
        removeLoadingScreen()
        delegate?.signInSuccess(user, for: authFlow)
    }
    
    func signInError(_ error: AuthError) {
        removeLoadingScreen()
        delegate?.signInFailure(error)
    }
}
