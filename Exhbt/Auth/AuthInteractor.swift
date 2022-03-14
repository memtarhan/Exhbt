//
//  AuthInteractor.swift
//  Exhbt
//
//  Created by Shouvik Paul on 4/20/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import FirebaseAuth
import Foundation

protocol AuthInteractorDelegate: AnyObject {
    func signInSuccess(_ user: User, for authFlow: AuthFlow)
    func signInError(_ error: AuthError)
    func failedToLoginFromDevice()
}

extension AuthInteractorDelegate {
    func failedToLoginFromDevice() {}
}

class AuthInteractor {
    weak var delegate: AuthInteractorDelegate?
    
    let authRepo = AuthRepository()
    let userRepo = UserRepository()
    let followRepo = FollowRepo()
    let blockedRepo = BlockRepo()
    let userManager = UserManager.shared
    let userDefaultsRepo = UserDefaultsRepository()
    
    func externalSignIn(
        for provider: AuthProvider,
        with credential: AuthCredential
    ) {
        authRepo.signInToFirebase(
            for: provider,
            with: credential
        ).then { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let user):
                let user = User(userID: user.uid, name: user.displayName, email: user.email)
                self.findOrCreateUser(user)
            case .failure(let error):
                print("\(provider.rawValue) sign in error: \(error)")
                self.delegate?.signInError(error)
            }
        }
    }
    
    func internalSignIn(
        email: String,
        password: String,
        authFlow: AuthFlow
    ) {
        switch authFlow {
        case .signup:
            createAccount(email: email, password: password)
        case .login:
            signIn(email: email, password: password)
        }
    }
    
    private func createAccount(email: String, password: String) {
        authRepo.createUser(email: email, password: password).then {
            [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let user):
                let user = User(
                    userID: user.uid,
                    email: email)
                self.createUser(user)
            case .failure(let error):
                print("Email password sign in error: \(error)")
                self.delegate?.signInError(error)
            }
        }
    }
    
    private func signIn(email: String, password: String) {
        authRepo.signIn(email: email, password: password).then {
            [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let user):
                let user = User(
                    userID: user.uid,
                    email: email)
                self.findOrCreateUser(user)
            case .failure(let error):
                print("Email password sign in error: \(error)")
                self.delegate?.signInError(error)
            }
        }
    }
    
    private func createUser(_ user: User) {
        self.userRepo.createUser(user).then {
            [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let user):
                self.signInSuccess(with: user, for: .signup)
            case .failure:
                self.delegate?.signInError(.createError)
            }
        }
    }
    
    private func findOrCreateUser(_ user: User) {
        self.userRepo.getUser(by: user.userID).then {
            [weak self] result in
            guard let self = self else { return }
            
            switch result {
                case .success(let user):
                    self.signInSuccess(with: user, for: .login)
                case .failure:
                    self.createUser(user)
            }
        }
    }
    
    private func signInSuccess(with user: User, for authFlow: AuthFlow) {
        userManager.login(user)
        getFollowers(for: user.userID)
        getFollowing(for: user.userID)
        getBlocked(for: user.userID)
        getBlockedBy(for: user.userID)
        
        delegate?.signInSuccess(user, for: authFlow)
    }
    
    func loginFromDevice() {
        guard let userID = userDefaultsRepo.getString(for: .userID) else {
            delegate?.failedToLoginFromDevice()
            return
        }
        
        userRepo.getUser(by: userID).then {
            [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let user):
                self.signInSuccess(with: user, for: .login)
            case .failure:
                self.delegate?.failedToLoginFromDevice()
            }
        }
    }
    
    func getFollowers(for userID: String) {
        followRepo.getFollowers(for: userID).then {
            [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let followers):
                self.userManager.followers = followers
                print("followers: \(self.userManager.followers)")
            case .failure(let error):
                print("Error getting followers for \(userID): \(error)")
            }
        }
    }
    
    func getFollowing(for userID: String) {
        followRepo.getFollowing(for: userID).then {
            [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let following):
                self.userManager.following = following
                print("following: \(self.userManager.following)")
            case .failure(let error):
                print("Error getting following for \(userID): \(error)")
            }
        }
    }
    
    func getBlocked(for userID: String) {
        blockedRepo.getBlockedUsers(for: userID).then {
            [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let blockedUsers):
                self.userManager.blockedUsers = blockedUsers
                print("blockedUsers: \(self.userManager.blockedUsers)")
            case .failure(let error):
                print("Error getting blocked users for \(userID): \(error)")
            }
        }
    }
    
    func getBlockedBy(for userID: String) {
        blockedRepo.getBlockedBy(for: userID).then {
            [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let blockedByUsers):
                self.userManager.blockedByUsers = blockedByUsers
                print("blockedByUsers: \(self.userManager.blockedByUsers)")
            case .failure(let error):
                print("Error getting blocked By Users for \(userID): \(error)")
            }
        }
    }
}
