//
//  SigninViewController.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 19/07/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import AuthenticationServices
import Combine
import SwiftUI
import UIKit

class SigninViewController: BaseViewController, Nibbable {
    var viewModel: SigninViewModel!

    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        setupReactiveComponents()        
    }

    private func setup() {
        let appleSigninButton = ASAuthorizationAppleIDButton()
        appleSigninButton.addTarget(self, action: #selector(handleSigninWithApple), for: .touchUpInside)
        appleSigninButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(appleSigninButton)

        let controller = UIHostingController(rootView: TermsPrivacyView())
        let termsPrivacyView = controller.view!
        termsPrivacyView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(termsPrivacyView)

        NSLayoutConstraint.activate([
            termsPrivacyView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            termsPrivacyView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            termsPrivacyView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            appleSigninButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 64),
            appleSigninButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -64),
            appleSigninButton.bottomAnchor.constraint(equalTo: termsPrivacyView.topAnchor, constant: -20),
            appleSigninButton.heightAnchor.constraint(equalToConstant: 45),
        ])

        controller.didMove(toParent: self)
    }

    private func setupReactiveComponents() {
        viewModel.willNavigateToHome
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.presentTabBar()
            }
            .store(in: &cancellables)

        viewModel.willNavigateToMissingDetails
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.presentMissingAccountDetails()
            }
            .store(in: &cancellables)
    }

    /// - Tag: perform_appleid_request
    @objc func handleSigninWithApple() {
        debugLog(self, #function)

        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
}

extension SigninViewController: ASAuthorizationControllerDelegate {
    /// - Tag: did_complete_authorization
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        debugLog(self, #function)
        startLoading()

        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:

            // Create an account in your system.
            let userIdentifier = appleIDCredential.user
//            let fullName = appleIDCredential.fullName
//            let email = appleIDCredential.email

            // For the purpose of this demo app, store the `userIdentifier` in the keychain.
            saveUserInKeychain(userIdentifier)

//            let name = "\(fullName?.givenName ?? "") \(fullName?.familyName ?? "")"

            // TODO: Pass full name to the next page if needed
            viewModel.signin(withIdentifier: userIdentifier)

            // For the purpose of this demo app, show the Apple ID credential information in the `ResultViewController`.
//            showResultViewController(userIdentifier: userIdentifier, fullName: fullName, email: email)

        case let passwordCredential as ASPasswordCredential:

            // Sign in using an existing iCloud Keychain credential.
            let username = passwordCredential.user
            let password = passwordCredential.password

            // For the purpose of this demo app, show the password credential as an alert.
            DispatchQueue.main.async {
                self.showPasswordCredentialAlert(username: username, password: password)
            }

        default:
            break
        }
    }

    private func saveUserInKeychain(_ userIdentifier: String) {
        do {
            try KeychainItem(service: "com.example.apple-samplecode.juice", account: "userIdentifier").saveItem(userIdentifier)
        } catch {
            print("Unable to save userIdentifier to keychain.")
        }
    }

    private func showResultViewController(userIdentifier: String, fullName: PersonNameComponents?, email: String?) {
//        guard let viewController = self.presentingViewController as? ResultViewController
//            else { return }
//
//        DispatchQueue.main.async {
//            viewController.userIdentifierLabel.text = userIdentifier
//            if let givenName = fullName?.givenName {
//                viewController.givenNameLabel.text = givenName
//            }
//            if let familyName = fullName?.familyName {
//                viewController.familyNameLabel.text = familyName
//            }
//            if let email = email {
//                viewController.emailLabel.text = email
//            }
//            self.dismiss(animated: true, completion: nil)
//        }
    }

    private func showPasswordCredentialAlert(username: String, password: String) {
        let message = "The app has received your selected credential from the keychain. \n\n Username: \(username)\n Password: \(password)"
        let alertController = UIAlertController(title: "Keychain Credential Received",
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = view
            popoverController.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = [] // No arrow for the popover
        }
        present(alertController, animated: true, completion: nil)
    }

    /// - Tag: did_complete_error
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
    }
}

extension SigninViewController: ASAuthorizationControllerPresentationContextProviding {
    /// - Tag: provide_presentation_anchor
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        debugLog(self, #function)
        return view.window!
    }
}

// MARK: - Navigations

extension SigninViewController: Router { }
