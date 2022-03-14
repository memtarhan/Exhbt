//
//  UserManager.swift
//  Exhbt
//
//  Created by Shouvik Paul on 4/12/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import Foundation

protocol UserManagerDelegate: AnyObject {
    func loggedOut()
}

class UserManager {
    static let shared = UserManager()
    
    let userDefaultsRepo = UserDefaultsRepository()
    var user: User?
    var followers: [Follow] = []
    var following: [Follow] = []
    var blockedUsers: [Block] = []
    var blockedByUsers: [Block] = []
    var userUpdated: Bool = false
    
    weak var delegate: UserManagerDelegate?
    
    fileprivate init() {}
    
    var isLoggedIn: Bool {
        return user != nil
    }
    
    func login(_ user: User) {
        print("user logged in: \(user)")
        setUser(user)
        userDefaultsRepo.setString(user.userID, for: .userID)
    }
    
    func logout() {
        user = nil
        userDefaultsRepo.setString(nil, for: .userID)
        delegate?.loggedOut()
    }
    
    func setUser(_ user: User) {
        self.user = user
        userUpdated = true
    }
    
    func hasCompletedProfile() -> Bool {
        return user?.name != nil && user?.name != ""
    }
}
