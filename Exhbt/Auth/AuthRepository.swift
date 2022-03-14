//
//  AuthRepository.swift
//  Exhbt
//
//  Created by Shouvik Paul on 4/12/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import FirebaseAuth
import CBGPromise

enum AuthProvider: String {
    case facebook, apple, email
}

enum AuthFlow {
    case signup
    case login
}

enum AuthType {
    case external
    case email
}

enum AuthError: Error {
    case createError
    case wrongPassword
    case userNotFound
    case emailInUse
    case weakPassword
    case unknown
}

class AuthRepository {
    func signInToFirebase(
        for provider: AuthProvider,
        with credential: AuthCredential
    ) -> Future<Result<FirebaseAuth.User, AuthError>> {
        
        let promise = Promise<Result<FirebaseAuth.User, AuthError>>()
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                promise.resolve(.failure(self.discernError(error as NSError)))
            } else if let authResult = authResult {
                promise.resolve(.success(authResult.user))
            } else {
                promise.resolve(.failure(AuthError.unknown))
            }
        }
        
        return promise.future
    }
    
    func createUser(
        email: String,
        password: String
    ) -> Future<Result<FirebaseAuth.User, AuthError>> {
        let promise = Promise<Result<FirebaseAuth.User, AuthError>>()
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                promise.resolve(.failure(self.discernError(error as NSError)))
            } else if let authResult = authResult {
                promise.resolve(.success(authResult.user))
            } else {
                promise.resolve(.failure(AuthError.unknown))
            }
        }
        
        return promise.future
    }
    
    func signIn(
        email: String,
        password: String
    ) -> Future<Result<FirebaseAuth.User, AuthError>> {
        let promise = Promise<Result<FirebaseAuth.User, AuthError>>()
        
        Auth.auth().signIn(withEmail: email, password: password) {
            authResult, error in
            if let error = error {
                promise.resolve(.failure(self.discernError(error as NSError)))
            } else if let authResult = authResult {
                promise.resolve(.success(authResult.user))
            } else {
                promise.resolve(.failure(AuthError.unknown))
            }
        }
        
        return promise.future
    }
    
    private func discernError(_ error: NSError) -> AuthError {
        switch error.code {
        case AuthErrorCode.wrongPassword.rawValue:
            return AuthError.wrongPassword
        case AuthErrorCode.userNotFound.rawValue,
             AuthErrorCode.invalidEmail.rawValue:
            return AuthError.userNotFound
        case AuthErrorCode.accountExistsWithDifferentCredential.rawValue,
             AuthErrorCode.credentialAlreadyInUse.rawValue,
             AuthErrorCode.emailAlreadyInUse.rawValue:
            return AuthError.emailInUse
        case AuthErrorCode.weakPassword.rawValue:
            return AuthError.weakPassword
        default:
            return AuthError.unknown
        }
    }
}
