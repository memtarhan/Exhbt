//
//  ProfileInteractor.swift
//  Exhbt
//
//  Created by Shouvik Paul on 6/6/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import UIKit

protocol ProfileInteractorDelegate: AnyObject {
    func updateSuccess(_ user: User)
    func updateFailure(_ error: Error)
    func uploadedAvaterImage(with ID: String)
    func failedToUploadAvatarImage(_ error: Error)
    func didRecieveRequestData(didRequest: Bool)
    func didRecieveFollowersData(followers: Int)
    func didRecieveUser(user: User)
}

class ProfileInteractor {
    weak var delegate: ProfileInteractorDelegate?
    
    private let userRepo = UserRepository()
    private let imageRepo = ImageRepository()
    private let followRepo = FollowRepo()
    private let notifRepo = NotificationRepository()
    private let blockRepo = BlockRepo()
    private let userManager = UserManager.shared
    
    func updateUser(_ user: User) {
        if user.userID == userManager.user?.userID {
            userRepo.updateUser(user).then {
                [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let user):
                    self.userManager.setUser(user)
                    self.delegate?.updateSuccess(user)
                case .failure(let error):
                    self.delegate?.updateFailure(error)
                }
            }
        } else {
            userRepo.getUser(by: user.userID).then {
                [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let user):
                    self.delegate?.updateSuccess(user)
                case .failure(let error):
                    self.delegate?.updateFailure(error)
                }
            }
        }
    }
    
    func uploadAvatarImage(_ image: UIImage) {
        imageRepo.uploadImage(image).then {
            [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let imageID):
                self.delegate?.uploadedAvaterImage(with: imageID)
                self.imageRepo.uploadImageForRestOfSizes(
                    image: image,
                    ID: imageID,
                    sizes: [.avatar, .tiny, .small])
            case .failure(let error):
                self.delegate?.failedToUploadAvatarImage(error)
            }
        }
    }
    
    func attemptToFollow(followedID: String) {
        guard let userID = userManager.user?.userID else { return }
        
        userRepo.getUser(by: followedID).then {
            [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let user):
                let notification: Notification
                if user.privateProfile {
                    notification = Notification(
                        userID: followedID,
                        type: .followRequest, creatorID: userID)
                } else {
                    notification = Notification(
                        userID: followedID,
                        type: .follow, creatorID: userID)
                    
                    _ = self.followRepo.follow(userID: userID, followedID: followedID)
                    self.userManager.following.append(Follow(userID: userID, followedID: followedID))
                }
                _ = self.notifRepo.sendNotification(notification)
            case .failure(let error):
                print("could not find user to follow \(followedID): \(error)")
            }
        }
    }
    
    func unfollow(followedID: String) {
        guard let userID = userManager.user?.userID else { return }
        
        followRepo.unfollow(userID: userID, followedID: followedID).then {
            [weak self] result in
            guard let self = self else { return }
            
            if case .success = result {
                self.userManager.following = self.userManager.following.filter { $0.userID != followedID }
            }
        }
    }
    
    func block(blockedID: String) {
        guard let userID = userManager.user?.userID else { return }
        
        _ = blockRepo.block(userID: userID, blockedID: blockedID)
        
        self.userManager.blockedUsers.append(Block(userID: userID, blockedID: blockedID))
        _ = self.followRepo.unfollow(userID: userID, followedID: blockedID)
        _ = self.followRepo.unfollow(userID: blockedID, followedID: userID)
        self.userManager.followers = self.userManager.followers.filter { $0.userID != blockedID }
        self.userManager.following = self.userManager.following.filter { $0.userID != blockedID }
    }
    
    func unblock(blockedID: String) {
        guard let userID = userManager.user?.userID else { return }
        
        _ = blockRepo.unblock(userID: userID, blockedID: blockedID)
        self.userManager.blockedUsers = self.userManager.blockedUsers.filter {
            $0.blockedID != blockedID
        }
    }
    
    func removeFollower(followerID: String) {
        guard let userID = userManager.user?.userID else { return }
        
        followRepo.unfollow(userID: followerID, followedID: userID).then {
            [weak self] result in
            guard let self = self else { return }
            
            if case .success = result {
                self.userManager.followers = self.userManager.followers.filter { $0.userID != followerID }
            }
        }
    }
    
    func findFollowRequest(followUserID: String) {
        guard let userID = userManager.user?.userID else { return }
        
        notifRepo.getFollowRequest(userID, followUserID: followUserID).then {
            [weak self] result in
            guard let self = self else { return }
            
            self.delegate?.didRecieveRequestData(didRequest: result)
        }
    }
    
    func getFollowers(for userID: String) {
        followRepo.getFollowers(for: userID).then {
            [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let followers):
                self.delegate?.didRecieveFollowersData(followers: followers.count)
            case .failure(let error):
                print("Error getting followers for \(userID): \(error)")
            }
        }
    }
    
    func getUser(by user: User) {
        userRepo.getUser(by: user.userID).then {
            [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let user):
                self.delegate?.didRecieveUser(user: user)
            case .failure:
                self.delegate?.didRecieveUser(user: user)
            }
        }
    }
}
