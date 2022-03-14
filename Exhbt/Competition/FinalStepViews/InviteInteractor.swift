//
//  InviteInteractor.swift
//  Exhbt
//
//  Created by Steven Worrall on 6/15/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import Foundation

protocol InviteInteractorDelegate: AnyObject {
    func didReceiveFollowing(users: [User])
    func errorRecievingData(error: Error)
}

class InviteInteractor {
    weak var delegate: InviteInteractorDelegate?
    let userRepo = UserRepository()
    let userManager = UserManager.shared
    let notifRepo = NotificationRepository()
    
    func getFollowing() {
        let userIDs = userManager.following.map { return $0.followedID }
        userRepo.getUsers(from: userIDs).then {
            [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let users):
                let updatedArray = users.filter {
                    return $0.userID != self.userManager.user?.userID
                }
                self.delegate?.didReceiveFollowing(users: updatedArray)
            case .failure(let error):
                self.delegate?.errorRecievingData(error: error)
            }
        }
    }
    
    func sendInvites(for userIDs: [String], competition: CompetitionDataModel) {
        _ = notifRepo.sendCompetitionInvites(for: userIDs, competition: competition)
    }
    
    func addCoinsForExternalInvite(creatorID: String) {
        guard let user = userManager.user, user.userID == creatorID else { return }
        userRepo.updateUser(user, coins: AppConstants.CoinsForVoting).then {
            [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let user):
                self.userManager.setUser(user)
            case .failure(let error):
                print("Error adding coins to user on vote: \(error)")
            }
        }
        
    }
}
