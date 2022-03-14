//
//  BlockInteractor.swift
//  Exhbt
//
//  Created by Shouvik Paul on 1/19/21.
//  Copyright © 2021 Exhbt LLC. All rights reserved.
//

import Foundation

protocol BlockInteractorDelegate: AnyObject {
    func didReceiveAllUsers(_ users: [User])
    func didReceiveUser(_ user: User)
    func errorReceivingUser(_ error: Error)
    
}

class BlockInteractor {
    weak var delegate: BlockInteractorDelegate?
    
    private let userManager = UserManager.shared
    private let userRepo = UserRepository()
    
    func getAllUsers() {
        userRepo.getAllUsers(returnBlocked: true).then {
            [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let users):
                let blockedIDs = self.userManager.blockedUsers.map { return $0.blockedID }
                var sortedUsers = users
                if let userID = self.userManager.user?.userID {
                    sortedUsers = sortedUsers.filter { return $0.userID != userID }
                }
                sortedUsers = users.map { (user: User) -> User in
                    if blockedIDs.contains(user.userID) {
                        user.selected = true
                    }
                    return user
                }
                sortedUsers = sortedUsers.sorted {
                    if $0.selected { return true }
                    if $1.selected { return false }
                    return true
                }
                self.delegate?.didReceiveAllUsers(sortedUsers)
            case .failure(let error):
                print("error getting alls users: \(error)")
            }
        }
    }
    
    func getUser(by userID: String) {
        userRepo.getUser(by: userID).then {
            [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let user):
                self.delegate?.didReceiveUser(user)
            case .failure(let error):
                self.delegate?.errorReceivingUser(error)
            }
        }
    }
}
